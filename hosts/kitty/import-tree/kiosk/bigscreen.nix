{ pkgs, home-manager, plasma-manager, ... }:
let
  bigscreen = pkgs.kdePackages.plasma-bigscreen;
in
{
  imports = [home-manager.nixosModules.default];

  home-manager.users.tv-session = {
    imports = [plasma-manager.homeModules.plasma-manager];
    home.stateVersion = "26.11";
    programs.plasma.powerdevil.AC.powerButtonAction = "shutDown";
  };

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
  environment.systemPackages = [ bigscreen ];

  # tv-session user
  users.users.tv-session = {
    isNormalUser = true;
  };

  # Necessary for bigscreen
  networking.networkmanager.enable = true;
  networking.networkmanager.unmanaged = [ "wlp58s0" ];
  programs.kdeconnect.enable = true;
}
