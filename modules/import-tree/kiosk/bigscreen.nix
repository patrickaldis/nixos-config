{pkgs, ...}:
let
  bigscreen = pkgs.kdePackages.plasma-bigscreen;
in{
  services.displayManager = {
    defaultSession = "plasma-bigscreen-wayland";
    autoLogin = {
      enable = true;
      user = "tv-session";
    };
    gdm = {
      enable = true;
    };
    sessionPackages = [
      bigscreen
    ];
  };
  services.desktopManager.plasma6.enable = true;
  environment.systemPackages = [bigscreen];

  # tv-session user
  users.users.tv-session = {
    isNormalUser = true;
  };

  # Necessary for bigscreen
  networking.networkmanager.enable = true;
  networking.networkmanager.unmanaged = [ "wlp58s0" ];
  programs.kdeconnect.enable = true;
}
