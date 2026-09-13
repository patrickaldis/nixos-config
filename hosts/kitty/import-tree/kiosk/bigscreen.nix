{ pkgs, home-manager, plasma-manager, ... }:
let
  bigscreen = pkgs.kdePackages.plasma-bigscreen;

  # Desktop-entry IDs (basename of the .desktop file) to hide from the
  # Bigscreen app grid. Plasma Bigscreen's launcher reads this list from
  # ~/.config/applications-blacklistrc and filters them out itself, rather
  # than us needing to touch the underlying packages' .desktop files.
  hiddenApplications = [
    "org.kde.ark"
    "org.kde.discover"
    "org.kde.dolphin"
    "org.kde.elisa"
    "org.kde.plasma.emojier"
    "org.kde.gwenview"
    "org.kde.khelpcenter"
    "org.kde.kinfocenter"
    "org.kde.kate"
    "org.kde.konsole"
    "org.kde.kwalletmanager"
    "org.kde.kwrite"
    "cups"
    "org.kde.kmenuedit"
    "nixos-manual"
    "org.kde.okular"
    "org.kde.qrca"
    "org.kde.spectacle"
    "org.kde.plasma-systemmonitor"
    "systemsettings"
    "org.kde.plasma.bigscreen.uvcviewer"
    "org.kde.drkonqi.coredump.gui"
    "org.kde.kdeconnect.app"
    "org.kde.kdeconnect.sms"
    "plasma-bigscreen-swap-session"
  ];
in
{
  imports = [ home-manager.nixosModules.default ];

  home-manager.useGlobalPkgs = true;
  home-manager.useUserPackages = true;

  home-manager.users.tv-session = {
    imports = [ plasma-manager.homeModules.plasma-manager ];
    home.stateVersion = "26.11";
    programs.plasma = {
      enable = true;
      overrideConfig = true;
      powerdevil.AC = {
        powerButtonAction = "shutDown";
        autoSuspend.action = "nothing";
        dimDisplay = {
          enable = true;
          idleTimeout = 60 * 10;
        };
        turnOffDisplay.idleTimeout = 60 * 15;
      };
      configFile."applications-blacklistrc"."Applications".blacklist =
        builtins.concatStringsSep "," hiddenApplications;
    };
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
