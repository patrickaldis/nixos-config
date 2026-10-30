{ config, secrets, ... }:
{
  age.secrets.nordvpn-wg.file = secrets + "/network/nordvpn-wg.age";

  networking.networkmanager.ensureProfiles = {
    environmentFiles = [ config.age.secrets.nordvpn-wg.path ];
    profiles.NordVPN = {
      connection = {
        id = "NordVPN";
        type = "wireguard";
        interface-name = "nordvpn0";
        autoconnect = false;
      };
      wireguard = {
        private-key = "$PrivateKey";
        private-key-flags = 0;
      };
      "wireguard-peer.K53l2wOIHU3262sX5N/5kAvCvt4r55lNui30EbvaDlE=" = {
        endpoint = "london.gb.wg.nordhold.net:51820";
        allowed-ips = "0.0.0.0/0;";
        persistent-keepalive = 25;
      };
      ipv4 = {
        method = "manual";
        address1 = "10.5.0.2/16";
        dns = "103.86.96.100;";
      };
      ipv6.method = "disabled";
    };
  };
}
