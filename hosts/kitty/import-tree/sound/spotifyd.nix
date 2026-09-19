{config, ...}:{
  systemd.services.spotifyd.serviceConfig.SupplementaryGroups = [ "audio" "pipewire" ];
  services.spotifyd = {
    enable = true;
    settings.global = {
      device_name = config.networking.hostName;
      backend = "pulseaudio";
      zeroconf_port = 4070;
      use_mpris = false;
    };
  };
  networking.firewall.allowedTCPPorts = [ 4070 ];
}
