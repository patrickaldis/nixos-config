{
  # kitty is the living-room kiosk, so a phone doubles as its remote: the media
  # layout drives whatever Bigscreen or Stremio is playing, and the pointer and
  # keyboard layouts cover everything Bigscreen's remote-friendly UI doesn't.
  # Events arrive through uinput, so Plasma sees them as an ordinary keyboard
  # and mouse.
  services.monpad = {
    enable = true;

    # Deliberate: monpad has no authentication, so this gives any device on the
    # same network full keyboard and mouse control of kitty. That is the point
    # here - it is a TV box on the home LAN, behind the router - but it does
    # mean the LAN is the whole security boundary.
    openFirewall = true;

    # /var/lib/monpad/address.png, encoding http://kitty.local:8000 - avahi
    # publishes addresses in ./wifi.nix, so the .local name resolves.
    writeQrCode = true;

    # Over wifi it is useful to be able to tell input lag from a weak signal.
    showPing = true;
  };
}
