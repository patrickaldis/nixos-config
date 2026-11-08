{ config, lib, pkgs, secrets, stremio, system, ... }:
let
  cfg = config.programs.stremio-vpn;
  stremioPkg = stremio.packages.${system}.default;

  # Reuses the same peer/address/dns as nordvpn.nix's NetworkManager profile,
  # just rendered as a wg-quick conf so vopono can use it directly.
  stremioVpnWrapper = pkgs.writeShellScript "stremio-local" ''
    set -euo pipefail

    conf=$(mktemp)
    trap 'rm -f "$conf"' EXIT

    . ${config.age.secrets.nordvpn-wg.path}

    cat > "$conf" <<EOF
    [Interface]
    PrivateKey = $PrivateKey
    Address = 10.5.0.2/16
    DNS = 103.86.96.100

    [Peer]
    PublicKey = K53l2wOIHU3262sX5N/5kAvCvt4r55lNui30EbvaDlE=
    Endpoint = london.gb.wg.nordhold.net:51820
    AllowedIPs = 0.0.0.0/0
    PersistentKeepalive = 25
    EOF
    chmod 600 "$conf"

    ${pkgs.vopono}/bin/vopono exec \
      --provider custom --custom "$conf" --protocol wireguard \
      -- ${stremioPkg}/bin/stremio-local "$@"
  '';
in
{
  options.programs.stremio-vpn = {
    enable = lib.mkEnableOption "running Stremio through a NordVPN WireGuard tunnel via vopono";

    user = lib.mkOption {
      type = lib.types.str;
      example = "patrick";
      description = ''
        User that launches Stremio. The wg secret is chowned to them so the
        unprivileged wrapper can render the conf, and they get the vopono
        sudo rule. Must be an actual user on the host.
      '';
    };
  };

  config = lib.mkIf cfg.enable {
    # mkDefault so a host that already declares this secret for its own
    # NordVPN setup (e.g. elizabeth's nordvpn.nix) keeps its definition.
    age.secrets.nordvpn-wg.file = lib.mkDefault (secrets + "/network/nordvpn-wg.age");

    # Readable by cfg.user so the unprivileged wrapper can render the wg conf;
    # vopono itself escalates to root via sudo when it needs to set up the netns.
    age.secrets.nordvpn-wg.owner = cfg.user;

    security.sudo.extraRules = [
      {
        users = [ cfg.user ];
        commands = [
          {
            command = "${pkgs.vopono}/bin/vopono";
            # SETENV: vopono re-execs itself via `sudo -E` to keep DISPLAY/
            # WAYLAND_DISPLAY/XDG_RUNTIME_DIR for the GUI app inside the netns.
            options = [ "NOPASSWD" "SETENV" ];
          }
        ];
      }
    ];

    # Same package, but bin/stremio-local is swapped for the VPN-wrapping
    # script above, so the existing desktop entry/icon/mime handler all keep
    # working unchanged while launching through vopono + NordVPN wireguard.
    environment.systemPackages = [
      # vopono shells out to wg/wg-quick to set up the tunnel.
      pkgs.wireguard-tools

      (pkgs.symlinkJoin {
        name = "stremio-vpn";
        paths = [ stremioPkg ];
        postBuild = ''
          rm -f $out/bin/stremio-local
          ln -s ${stremioVpnWrapper} $out/bin/stremio-local
        '';
      })
    ];
  };
}
