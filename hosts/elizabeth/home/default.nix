{
  pkgs,
  inputs,
  lib,
  config,
  ...
}:
{
  xdg.autostart.enable = true;

  services.udiskie = {
    enable = true;
    tray = "never";
    settings = {
      mountDir = "/mnt";
    };
  };

  home = {
    homeDirectory = "/home/patrick";
    stateVersion = "26.11";

    packages = (
      with pkgs;
      [
        ripgrep
        nurl
        wl-clipboard
        xfce4-power-manager
        teamtype
        dex
        meld
        gamescope

        walker
        elephant
        joplin-desktop
        abcde
        eyed3
        lame
        opencode
        anki-bin
        gnome-online-accounts-gtk
        geary

        zulip

        # vscode
        vesktop
        emacs-pgtk
        spotify
        evince
        loupe
        nautilus
        wdisplays
        signal-desktop
        mailspring
        steam
        obs-studio
        libreoffice-fresh
        gnome-calendar
        dbeaver-bin

        broot
        zapzap
      ]
    );
  };
  programs = {
    direnv = {
      enable = true;
      nix-direnv.enable = true;
      silent = true;
    };
    mangohud = {
      enable = true;
    };
    zoxide.enable = true;
    git = {
      enable = true;
      settings = {
        user = {
          name = "Patrick Aldis";
          email = "patricktaldis@gmail.com";
        };
      };
      ignores = [
        ".direnv"
        ".envrc"
        ".nvim.lua"
      ];
    };
    ssh = {
      enable = true;
      enableDefaultConfig = false;
    };
  };

  systemd.user.services.elephant = {
    Unit = {
      Description = "Elephant";
      After = [ "graphical-session.target" ];
    };
    Service = {
      Type = "simple";
      ExecStart = "${pkgs.elephant}/bin/elephant";
      Restart = "on-failure";
    };
    Install = {
      WantedBy = [ "graphical-session.target" ];
    };
  };

  services.xembed-sni-proxy.enable = true;
}
