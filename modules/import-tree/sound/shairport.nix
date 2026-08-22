{pkgs, ...}:{
  services.shairport-sync = {
    enable = true;
    arguments = "-a 'Magic Box'";
    package = pkgs.shairport-sync-airplay2;
    openFirewall = true;
    settings = {
      diagnostics = {
        log_verbosity = 1;
      };
      general = {
        output_backend = "pipewire";
      };
    };
  };
  security.rtkit.enable = true;
  users.users.shairport.extraGroups = [ "pipewire" ];
}
