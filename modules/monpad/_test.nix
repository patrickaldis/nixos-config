/*
  VM test for the monpad module. Underscore-prefixed so import-tree skips it;
  it is wired up as `checks.<system>.monpad` in flake.nix and run with
  `nix build .#checks.x86_64-linux.monpad`.

  The interesting thing to prove is not that the web server comes up, but that
  the Dhall layouts in ./dhall survive the whole pipeline: specialised to evdev
  at build time, decoded by monpad's Haskell layout decoder at startup, and
  turned into virtual input devices whose capabilities are exactly the keys and
  axes the layouts asked for. So the test connects a real websocket client,
  then inspects the devices that appear and replays a click through one.
*/
{
  nixpkgs,
  monpad,
  system,
}:
let
  pkgs = import nixpkgs { inherit system; };

  # websocket-client for the client half of the protocol, evdev to read back
  # the virtual devices monpad creates for it.
  python = pkgs.python3.withPackages (ps: [
    ps.websocket-client
    ps.evdev
  ]);

  # Expected capabilities per layout, derived by hand from ./dhall/*.dhall. If
  # a layout changes, this is the list to update.
  expected = {
    pointer = {
      keys = [
        "BTN_LEFT"
        "BTN_MIDDLE"
        "BTN_RIGHT"
      ];
      rel = [
        "REL_X"
        "REL_Y"
        "REL_WHEEL"
      ];
    };
    keyboard = {
      keys = [
        "KEY_Q"
        "KEY_P"
        "KEY_A"
        "KEY_L"
        "KEY_Z"
        "KEY_M"
        "KEY_COMMA"
        "KEY_DOT"
        "KEY_SLASH"
        "KEY_SPACE"
        "KEY_ENTER"
        "KEY_BACKSPACE"
        "KEY_LEFTSHIFT"
        "KEY_LEFTCTRL"
        "KEY_LEFTALT"
        "KEY_LEFTMETA"
        "KEY_ESC"
        "KEY_TAB"
      ];
      rel = [ ];
    };
    navigation = {
      keys = [
        "KEY_UP"
        "KEY_DOWN"
        "KEY_LEFT"
        "KEY_RIGHT"
        "KEY_ENTER"
        "KEY_ESC"
        "KEY_TAB"
        "KEY_LEFTMETA"
        "KEY_PAGEUP"
        "KEY_PAGEDOWN"
        "KEY_BACKSPACE"
      ];
      rel = [ ];
    };
    media = {
      keys = [
        "KEY_PLAYPAUSE"
        "KEY_PREVIOUSSONG"
        "KEY_NEXTSONG"
        "KEY_VOLUMEUP"
        "KEY_VOLUMEDOWN"
        "KEY_MUTE"
        "KEY_BRIGHTNESSUP"
        "KEY_BRIGHTNESSDOWN"
      ];
      rel = [ ];
    };
  };

  checkScript = pkgs.writeText "monpad-check.py" ''
    import json, select, sys, time, urllib.request
    import evdev, websocket

    EXPECTED = json.loads(${builtins.toJSON (builtins.toJSON expected)})
    USER = "tester"
    BASE = "localhost:8000"

    def fail(msg):
        print("FAIL: " + msg, file=sys.stderr)
        sys.exit(1)

    before = set(evdev.list_devices())

    # The login page GET is what puts the username in monpad's "waiting" set;
    # the websocket handler rejects any client that skipped it.
    page = urllib.request.urlopen(f"http://{BASE}/?username={USER}").read().decode()
    if 'name="username"' in page:
        fail("got the login page back, so the username was rejected: " + page[:400])

    ws = websocket.create_connection(f"ws://{BASE}/?username={USER}", timeout=10)

    # Devices are created in onNewConnection, before the handshake completes,
    # but udev still has to get round to creating the nodes.
    devices = {}
    for _ in range(50):
        time.sleep(0.2)
        devices = {}
        for path in set(evdev.list_devices()) - before:
            d = evdev.InputDevice(path)
            if d.name.startswith("Monpad: "):
                devices[d.name] = d
        if len(devices) >= len(EXPECTED):
            break

    print("devices created:", sorted(devices))
    if len(devices) != len(EXPECTED):
        fail(f"expected {len(EXPECTED)} devices, got {sorted(devices)}")

    for layout, want in EXPECTED.items():
        name = f"Monpad: {layout} ({USER})"
        dev = devices.get(name)
        if dev is None:
            fail(f"no device named {name!r}; have {sorted(devices)}")
        caps = dev.capabilities(verbose=True)
        got_keys = {n for n, _ in caps.get(("EV_KEY", evdev.ecodes.EV_KEY), [])}
        got_rel = {n for n, _ in caps.get(("EV_REL", evdev.ecodes.EV_REL), [])}
        # evdev reports aliased codes as tuples of names, so flatten.
        def flat(s):
            out = set()
            for n in s:
                out.update(n if isinstance(n, tuple) else (n,))
            return out
        got_keys, got_rel = flat(got_keys), flat(got_rel)
        missing = [k for k in want["keys"] if k not in got_keys]
        missing += [r for r in want["rel"] if r not in got_rel]
        if missing:
            fail(f"{layout}: missing {missing}; device has keys={sorted(got_keys)} rel={sorted(got_rel)}")
        print(f"{layout}: {len(got_keys)} keys, {len(got_rel)} rel axes - all expected present")

    # Now replay a real click. "pointer" is the first layout, so it is the one
    # a fresh client's events are routed to, and "Left" is its BTN_LEFT button.
    ptr = devices[f"Monpad: pointer ({USER})"]
    ws.send(json.dumps({"ButtonDown": "Left"}))
    ws.send(json.dumps({"ButtonUp": "Left"}))

    seen = []
    deadline = time.time() + 10
    while time.time() < deadline and len(seen) < 2:
        if select.select([ptr.fd], [], [], 0.5)[0]:
            for e in ptr.read():
                if e.type == evdev.ecodes.EV_KEY and e.code == evdev.ecodes.BTN_LEFT:
                    seen.append(e.value)

    print("BTN_LEFT values seen:", seen)
    if seen != [1, 0]:
        fail(f"expected a press then a release (1, 0), got {seen}")

    # Writing evdev events is only half the job: a Wayland compositor gets its
    # input through libinput, which only sees devices udev has tagged into a
    # seat. Virtual devices are not special-cased anywhere, so this should fall
    # out of the stock 60-input-id/71-seat rules - but it is the step that
    # decides whether any of this reaches the desktop, so assert it.
    #
    # systemd's rule is `SUBSYSTEM=="input", KERNEL=="input*", TAG+="seat"`, so
    # the tag lands on the parent inputN device, not on the eventN node.
    import subprocess

    def props(args):
        out = subprocess.run(
            ["udevadm", "info", "--query=property"] + args,
            capture_output=True, text=True, check=True,
        ).stdout
        return dict(l.split("=", 1) for l in out.splitlines() if "=" in l)

    for name, dev in sorted(devices.items()):
        syspath = subprocess.run(
            ["udevadm", "info", "--query=path", "--name", dev.path],
            capture_output=True, text=True, check=True,
        ).stdout.strip()
        parent = syspath.rsplit("/", 1)[0]
        ev, par = props(["--name", dev.path]), props(["--path", parent])
        if "seat" not in par.get("TAGS", ""):
            fail(f"{name}: parent {parent} not tagged into a seat: "
                 f"TAGS={par.get('TAGS')!r}")
        if ev.get("ID_INPUT") != "1":
            fail(f"{name}: udev did not recognise it as an input device: "
                 f"ID_INPUT={ev.get('ID_INPUT')!r}")
        kinds = sorted(k for k in ev if k.startswith("ID_INPUT_"))
        print(f"{name}: seat={par.get('ID_SEAT', 'seat0 (default)')} "
              f"{' '.join(kinds)}")

    ws.close()
    print("OK")
  '';
in
pkgs.testers.runNixOSTest {
  name = "monpad";

  node.specialArgs = { inherit monpad system; };

  nodes.machine =
    { ... }:
    {
      imports = [ ./default.nix ];

      services.monpad = {
        enable = true;
        # Binary is the default encoding; JSON lets the test craft updates by
        # hand rather than reimplementing monpad's binary format.
        extraArgs = [ "--json" ];
        verbosity = 3;
      };

      environment.systemPackages = [
        python
        pkgs.curl
      ];
      virtualisation.memorySize = 2048;
    };

  testScript = ''
    machine.wait_for_unit("monpad.service")
    machine.wait_for_open_port(8000)

    # No username parameter: monpad serves the login page instead.
    login = machine.succeed("curl -sS http://localhost:8000/")
    assert 'name="username"' in login, f"login page has no username field:\n{login}"

    # The module runs monpad unprivileged, so this is also a check that the
    # uinput group plus DeviceAllow is enough to open /dev/uinput under
    # ProtectSystem=strict and friends.
    machine.succeed("systemctl show -p User,Group monpad.service | tee /dev/stderr | grep -q User=monpad")

    print(machine.succeed("${python}/bin/python3 ${checkScript} 2>&1"))

    machine.succeed("systemctl is-active monpad.service")
  '';
}
