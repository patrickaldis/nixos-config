/*
  monpad (https://github.com/georgefst/monpad) serves a web page that turns a
  phone's touchscreen into an input device for this machine: it creates virtual
  evdev devices through /dev/uinput and replays taps and drags into them as
  real key and pointer events. Because the events enter at the kernel level,
  every application sees them as ordinary keyboard and mouse input - nothing
  needs to know monpad exists.

  The layouts in ./dhall are keyboard and mouse oriented: a trackpad, a full
  QWERTY keyboard, a navigation d-pad, and media keys.

  SECURITY: monpad has no authentication and no TLS - the login page only asks
  for a display name, and anything that can reach the port has full keyboard
  and mouse control of this machine. Keep it to a network you trust, and leave
  `openFirewall` off unless you mean it.
*/
{
  config,
  lib,
  pkgs,
  monpad,
  system,
  ...
}:
let
  cfg = config.services.monpad;

  # Upstream's dhall/lib/Prelude.dhall is a remote import pinned by hash, and
  # the build sandbox has no network. nixpkgs ships the Prelude as a local
  # store path plus a pre-populated Dhall cache, so substituting it in resolves
  # the same imports offline. Only List.map, List.indexed and Integer.add are
  # used, all long-stable across Prelude versions.
  prelude = pkgs.dhallPackages.Prelude;

  # The tree each layout is resolved in. Mirrors the shape of monpad's own
  # dhall/ directory so that the relative imports in ./dhall/*.dhall - and in
  # any layout a user adds - resolve exactly as they do upstream.
  layoutTree = pkgs.runCommand "monpad-dhall-tree" { } ''
    mkdir -p $out
    cp -r ${monpad}/dhall/lib $out/lib
    cp ${./dhall/common.dhall} $out/common.dhall
    ${lib.concatMapStringsSep "\n" (
      l: "cp ${l.source} $out/${l.name}.dhall"
    ) cfg.layouts}
    ${lib.concatStringsSep "\n" (
      lib.mapAttrsToList (name: src: "cp ${src} $out/${name}") cfg.extraDhallFiles
    )}
    chmod -R u+w $out
    printf '%s/binary.dhall\n' ${prelude} > $out/lib/Prelude.dhall
  '';

  # monpad's Linux backend decodes layouts as `Layout Evdev.AxisInfo
  # Evdev.Key`, but the layouts are written against the OS-generic types, so
  # each one is specialised through `map-layout.dhall`'s `toLinux` and then
  # fully resolved. This is what upstream's Build.hs does for `dist/dhall/*`,
  # moved to build time so that a bad layout fails the rebuild rather than the
  # service.
  resolveLayout =
    name:
    pkgs.runCommand "monpad-layout-${name}.dhall"
      {
        nativeBuildInputs = [ pkgs.dhall ];
      }
      ''
        cp -r ${layoutTree}/. .
        chmod -R u+w .

        # dhall insists on a writable cache even when every import is local.
        export HOME=$PWD
        export XDG_CACHE_HOME=$PWD/.cache
        mkdir -p $XDG_CACHE_HOME
        cp -r ${prelude}/.cache/dhall $XDG_CACHE_HOME/
        chmod -R u+w $XDG_CACHE_HOME

        echo '(./lib/map-layout.dhall).toLinux (./${name}.dhall)' > wrap.dhall
        dhall --file wrap.dhall > $out
      '';

  # `--layout` takes a Dhall expression, and a bare absolute path is an import
  # expression. The resolved files have no imports left, so nothing is read
  # beyond the file itself. The first one given is the layout clients start on.
  layoutArgs = map (l: "--layout ${resolveLayout l.name}") cfg.layouts;

  args =
    [
      "--port ${toString cfg.port}"
      "-v ${toString cfg.verbosity}"
    ]
    ++ layoutArgs
    ++ lib.optional (cfg.windowTitle != null) "--window-title ${lib.escapeShellArg cfg.windowTitle}"
    ++ lib.optional (cfg.loginPageTitle != null) "--login-title ${lib.escapeShellArg cfg.loginPageTitle}"
    ++ lib.optional cfg.showPing "--show-ping"
    ++ lib.optional (cfg.deadzone != null) "--deadzone ${toString cfg.deadzone}"
    ++ cfg.extraArgs;

  advertisedAddress =
    if cfg.advertisedAddress != null then
      cfg.advertisedAddress
    else
      "http://${config.networking.hostName}.local:${toString cfg.port}";

  layoutModule = {
    options = {
      name = lib.mkOption {
        type = lib.types.strMatching "[A-Za-z0-9_-]+";
        description = ''
          Identifier for this layout. Used as the Dhall filename inside the
          build tree, so it must be unique; the name clients actually see is
          the layout's own `name` field.
        '';
      };
      source = lib.mkOption {
        type = lib.types.path;
        description = ''
          A Dhall file evaluating to `monpad.Layout` over the OS-generic axis
          and button types - that is, the same thing upstream's dhall/*.dhall
          evaluate to. It is specialised to evdev and resolved at build time.

          `./common.dhall` and `./lib/*.dhall` are available as relative
          imports, as are any {option}`services.monpad.extraDhallFiles`.
        '';
      };
    };
  };
in
{
  options.services.monpad = {
    enable = lib.mkEnableOption "monpad, a web-based remote keyboard and mouse for this machine";

    package = lib.mkOption {
      type = lib.types.package;
      default = monpad.packages.${system}."monpad:exe:monpad";
      defaultText = lib.literalExpression ''monpad.packages.''${system}."monpad:exe:monpad"'';
      description = ''
        The monpad executable. The default is the haskell.nix build from the
        flake input, which needs `allow-import-from-derivation` (on by default)
        and is worth pointing `georgefst.cachix.org` at - see
        modules/nix-config.nix.
      '';
    };

    port = lib.mkOption {
      type = lib.types.port;
      default = 8000;
      description = "Port for the web interface. monpad listens on all interfaces; it has no option to bind one.";
    };

    openFirewall = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = ''
        Open {option}`services.monpad.port` to every interface.

        monpad has no authentication whatsoever, so this grants keyboard and
        mouse control of the machine to anything that can route to it. Prefer
        {option}`networking.firewall.interfaces` to scope it to one trusted
        network, or reach it over a VPN or an SSH tunnel.
      '';
    };

    layouts = lib.mkOption {
      type = lib.types.nonEmptyListOf (lib.types.submodule layoutModule);
      default = [
        {
          name = "pointer";
          source = ./dhall/pointer.dhall;
        }
        {
          name = "keyboard";
          source = ./dhall/keyboard.dhall;
        }
        {
          name = "navigation";
          source = ./dhall/navigation.dhall;
        }
        {
          name = "media";
          source = ./dhall/media.dhall;
        }
      ];
      defaultText = lib.literalExpression "the four layouts in modules/monpad/dhall";
      description = ''
        Layouts offered to clients, in order; the first is the one they start
        on. With more than one, monpad enables its layout-switcher plugin,
        which adds a button for cycling between them.

        Each layout becomes its own virtual evdev device, created per client on
        connection and advertising exactly the keys and axes that layout uses.
      '';
    };

    extraDhallFiles = lib.mkOption {
      type = lib.types.attrsOf lib.types.path;
      default = { };
      example = lib.literalExpression ''{ "my-helpers.dhall" = ./my-helpers.dhall; }'';
      description = ''
        Extra files to place alongside the layouts in the Dhall build tree, so
        custom layouts can import shared helpers of their own. Keys are
        filenames, including the extension.
      '';
    };

    verbosity = lib.mkOption {
      type = lib.types.ints.between 0 3;
      default = 1;
      description = "How much monpad logs about client messages. 0 is silent, 3 logs every event.";
    };

    showPing = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Show each client its current ping in the corner of the screen. Useful for telling input lag from a flaky network.";
    };

    writeQrCode = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = ''
        Write a QR code of {option}`services.monpad.advertisedAddress` to
        `/var/lib/monpad/address.png`, to scan instead of typing an address
        into the phone.

        Generated here with qrencode rather than through monpad's own `--qr`:
        on this branch `getLocalIp` is stubbed out to `pure Nothing`, so
        everything monpad derives the address from - the QR code and the
        "started at" log line - says `localhost`, which is no use to a phone.
      '';
    };

    advertisedAddress = lib.mkOption {
      type = lib.types.nullOr lib.types.str;
      default = null;
      defaultText = lib.literalExpression ''"http://''${config.networking.hostName}.local:''${port}"'';
      example = "http://192.168.1.20:8000";
      description = ''
        The URL to put in the QR code. The default relies on the host
        resolving over mDNS, which needs {option}`services.avahi.publish` on
        this machine and a resolver on the phone - set an address explicitly if
        that is not the case.
      '';
    };

    windowTitle = lib.mkOption {
      type = lib.types.nullOr lib.types.str;
      default = null;
      description = "Browser title for the controller page. monpad's own default is \"monpad\".";
    };

    loginPageTitle = lib.mkOption {
      type = lib.types.nullOr lib.types.str;
      default = null;
      description = ''
        Heading on the page that asks for a display name. monpad always shows
        this page; the name it collects labels the client's virtual devices and
        picks its colour.
      '';
    };

    deadzone = lib.mkOption {
      # numbers.between rather than float, so a plain `0` or `1` is accepted.
      type = lib.types.nullOr (lib.types.numbers.between 0 1);
      default = null;
      example = 0.1;
      description = ''
        Give every non-zero joystick event at least this magnitude (0 to 1), to
        push past a deadzone applied downstream. Not usually wanted for pointer
        control, where the events are relative.
      '';
    };

    extraArgs = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [ ];
      example = [ "--scale 1.5" ];
      description = "Extra arguments for monpad. See `monpad --help`.";
    };
  };

  config = lib.mkIf cfg.enable {
    # Loads the uinput module, creates the uinput group, and installs the udev
    # rule that gives that group 0660 on /dev/uinput - the setup monpad's
    # README asks for by hand.
    hardware.uinput.enable = true;

    users.users.monpad = {
      isSystemUser = true;
      group = "monpad";
      description = "monpad remote input server";
    };
    users.groups.monpad = { };

    environment.systemPackages = [ cfg.package ];

    networking.firewall.allowedTCPPorts = lib.mkIf cfg.openFirewall [ cfg.port ];

    systemd.services.monpad = {
      description = "monpad remote keyboard and mouse server";
      wantedBy = [ "multi-user.target" ];
      after = [ "network.target" ];

      serviceConfig = {
        ExecStart = "${cfg.package}/bin/monpad ${lib.concatStringsSep " " args}";
        ExecStartPre = lib.mkIf cfg.writeQrCode (
          pkgs.writeShellScript "monpad-qr" ''
            ${lib.getExe pkgs.qrencode} -s 8 -m 2 \
              -o "$STATE_DIRECTORY/address.png" ${lib.escapeShellArg advertisedAddress}
            # UMask below is 0077, but the whole point is for a human to open it.
            chmod 0644 "$STATE_DIRECTORY/address.png"
          ''
        );
        Restart = "on-failure";
        RestartSec = 5;

        User = "monpad";
        Group = "monpad";
        # Write access to /dev/uinput is all monpad needs to create devices.
        # (Not PrivateUsers: a user namespace wouldn't map this group through,
        # which is exactly the access being granted.)
        SupplementaryGroups = [ "uinput" ];
        StateDirectory = "monpad";
        StateDirectoryMode = "0755";

        # PrivateDevices would replace /dev wholesale and hide uinput, so
        # instead keep the host /dev but allow nothing else out of it.
        DevicePolicy = "closed";
        DeviceAllow = [ "/dev/uinput rw" ];

        NoNewPrivileges = true;
        CapabilityBoundingSet = [ "" ];
        AmbientCapabilities = [ "" ];
        ProtectSystem = "strict";
        ProtectHome = true;
        PrivateTmp = true;
        ProtectClock = true;
        ProtectHostname = true;
        ProtectKernelLogs = true;
        ProtectKernelModules = true;
        ProtectKernelTunables = true;
        ProtectControlGroups = true;
        ProtectProc = "invisible";
        ProcSubset = "pid";
        RestrictNamespaces = true;
        RestrictRealtime = true;
        RestrictSUIDSGID = true;
        LockPersonality = true;
        RemoveIPC = true;
        RestrictAddressFamilies = [
          "AF_INET"
          "AF_INET6"
          "AF_UNIX"
        ];
        SystemCallFilter = [
          "@system-service"
          "~@privileged"
        ];
        SystemCallArchitectures = "native";
        UMask = "0077";
      };
    };
  };
}
