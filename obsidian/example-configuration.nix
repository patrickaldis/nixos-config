# Sets up a machine with the default O.S. nixos config
# Before using: 
# * Set "networking.hostName" 
# * Set "services.xserver.videoDrivers"

{ config, pkgs, ... }:

{
  imports =
    [
      ./hardware-configuration.nix
      ./obsidian
      ./obsidian/machines.nix
      ./obsidian/users
    ];

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  networking.hostName = "sample";
  networking.networkmanager.enable = true;

  time.timeZone = "America/New_York";

  environment.systemPackages = with pkgs; [
    wget vim tmux
  ];
  nixpkgs.config.allowUnfree = true;

  services.openssh.enable = true;

  # Enable sound.
  sound.enable = true;
  hardware.pulseaudio.enable = true;

  # Enable the X11 windowing system.
  services.xserver.videoDrivers = ["intel"];
  services.xserver.enable = true;
  services.xserver.layout = "us";

  # Enable touchpad support.
  services.xserver.libinput.enable = true;

  # Enable the KDE Desktop Environment.
  services.xserver.displayManager.sddm.enable = true;
  services.xserver.desktopManager.plasma5.enable = true;

  system.stateVersion = "18.09"; # Did you read the comment?

}
