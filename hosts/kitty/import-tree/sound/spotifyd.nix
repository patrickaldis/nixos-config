{config, ...}:{
  systemd.services.spotifyd.serviceConfig.SupplementaryGroups = [ "audio" "pipewire" ];
  services.spotifyd = {
    enable = true;
    settings.global = {
      device_name = config.networking.hostName;
      backend = "pulseaudio";
      device = "alsa_output.pci-0000_00_1f.3.analog-stereo"; # Headphone jack
      zeroconf_port = 4070;
      use_mpris = false;
    };
  };
  networking.firewall.allowedTCPPorts = [ 4070 ];
}
