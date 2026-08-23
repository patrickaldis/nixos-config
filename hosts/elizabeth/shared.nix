({ pkgs, ... }: {
  nixpkgs.config.allowUnfree = true;

  boot.loader = {
    efi.canTouchEfiVariables = true;
    systemd-boot.enable = true;
  };

  services.logind.settings.Login = {
    HandleLidSwitch = "suspend";
  };

  services.avahi = {
    enable = true;
    nssmdns4 = true; # adds mdns to nsswitch.conf for IPv4
  };

  console = {
    font = "ter-v32n";
    packages = with pkgs; [ terminus_font ];
  };

  fonts.packages = with pkgs; [
    nerd-fonts.jetbrains-mono
    noto-fonts-cjk-sans
    lmodern
  ];

  # VIRTUALISATION
  virtualisation = {
    libvirtd.enable = true;
    kvmgt.enable = true;
    spiceUSBRedirection.enable = true;
    docker.enable = true;
  };

  services.openssh.enable = true;

  networking = {
    networkmanager = {
      enable = true;
      plugins = with pkgs; [
        networkmanager-openvpn
      ];
    };
  };

  services.xserver.desktopManager.runXdgAutostartIfNone = true;

  programs.kdeconnect.enable = true;
  programs.gnome-disks.enable = true;
  security.polkit.enable = true;

  time.timeZone = "Europe/London"; # LOCALE
  i18n.defaultLocale = "en_GB.UTF-8";
  console.keyMap = "uk";

  hardware.bluetooth.enable = true; # SOUND
  hardware.graphics = {
    enable = true;
    enable32Bit = true;
  };

  security.rtkit.enable = true;

  # UPOWER
  services.upower = {
    enable = true;
    percentageLow = 20;
    percentageCritical = 5;
  };

  # USER SETUP
  users.users.patrick = {
    shell = pkgs.fish;
    extraGroups = [
      "wheel"
      "docker"
    ];
    isNormalUser = true;
  };

  # SHELL
  programs.fish.enable = true;
  environment.shells = with pkgs; [ fish ];

  # ENVIRONMENT VARIABLES
  environment = {
    sessionVariables = {
      TERMINAL = "kitty";
      EDITOR = "nvim";
      MANPAGER = "nvim +Man!";
      PAGER = "nvim +Man!";
      fish_greeting = "";
      QT_STYLE_OVERRIDE = "adwaita";
      NIXOS_OZONE_WL = "1";
      ANKI_WAYLAND = "1";
      BAT_PAGER = "less -R --use-color -X --no-init";
      LESS = "-R";
      NIX_IGNORE_WARNINGS = 1;
      MANGOHUD = 1;
    };
  };

  services.gnome.gnome-online-accounts.enable = true;
  services.gnome.sushi.enable = true;

  # CRON
  services.cron.enable = true;
  services.cron.systemCronJobs = [ "@reboot rm -r -f home/patrick/Downloads/*" ];

  # NIX DAEMON
  nix.settings = {
    substituters = [
      "https://hyprland.cachix.org"
      "https://nix-community.cachix.org"
      "https://cache.iog.io"
      "https://helix.cachix.org"
      "https://georgefst.cachix.org"
      "https://cache.zw3rk.com"
    ];
    trusted-public-keys = [
      "hyprland.cachix.org-1:a7pgxzMz7+chwVL3/pzj6jIBMioiJM7ypFP8PwtkuGc="
      "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
      "hydra.iohk.io:f/Ea+s+dFdN+3Y/G+FDgSq+a5NEWhJGzdjvKNGv0/EQ="
      "helix.cachix.org-1:ejp9KQpR1FBI2onstMQ34yogDm4OgU2ru6lIwPvuCVs="
      "georgefst.cachix.org-1:vuSIhlomQ+gIylNOJUXEnzRhtvYvHzUrpT/ezaN0kX8="
      "loony-tools:pr9m4BkM/5/eSTZlkQyRt57Jz7OMBxNSUiMC4FkcNfk="
    ];
    experimental-features = [
      "nix-command"
      "flakes"
    ];
    trusted-users = [ "patrick" ];
  };

  services.dbus.enable = true;
  services.gnome.at-spi2-core.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
  };

  services.playerctld.enable = true;

  services.xserver = {
    enable = true;
    xkb = {
      layout = "gb";
      variant = "";
    };
    desktopManager.xterm.enable = false;
  };

  services.displayManager.sessionPackages = [
    pkgs.gnome-session.sessions
  ];

  services.gvfs.enable = true;

  services.displayManager.gdm = {
    enable = true;
  };

  # BLUEMAN
  services.blueman.enable = true;

  # PRINTING
  services.printing.enable = true;

  # FLATPAK
  services.flatpak.enable = true;

  # UDEV
  services.udev.packages = [
    (pkgs.writeTextFile {
      name = "backlightudev";
      text = ''
        ACTION=="add", SUBSYSTEM=="backlight", RUN+="${pkgs.coreutils}/bin/chgrp video /sys/class/backlight/%k/brightness"
        ACTION=="add", SUBSYSTEM=="backlight", RUN+="${pkgs.coreutils}/bin/chmod g+w /sys/class/backlight/%k/brightness" '';
      destination = "/lib/udev/rules.d/99-swayosd.rules";
    })

    (pkgs.writeTextFile {
      name = "udiskudev";
      text = ''
        ENV{ID_FS_USAGE}=="filesystem|other|crypto", ENV{UDISKS_FILESYSTEM_SHARED}="1"
      '';
      destination = "/lib/udev/rules.d/99-udisk2.rules";
    })
    (pkgs.gnome-settings-daemon)
  ];

  programs.dconf.enable = true;
  programs.xfconf.enable = true;

  # GNOME KEYRING
  services.gnome.gnome-keyring.enable = true;
  security.pam.services.gdm-password.enableGnomeKeyring = true;

  environment.systemPackages = with pkgs; [
    cachix
    socat
    htop-vim
    tree
    wget
    swaybg
    killall
    udiskie
    waybar
    nix-output-monitor
    zed-editor
    mpv
    neovim
    claude-code

    networkmanagerapplet
    pavucontrol

    libappindicator-gtk3
    libappindicator-gtk2
    libayatana-appindicator

    adwaita-icon-theme
    adwaita-qt

    wofi
    kitty
  ];

  services.fprintd = {
    enable = true;
  };

  programs.sway.enable = true;
  programs.niri.enable = true;
})
