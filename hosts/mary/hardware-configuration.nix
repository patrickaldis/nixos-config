# Scanned by ‘nixos-generate-config’ on the machine that used to run the
# obsidian-laptop configuration (Framework Laptop 13, AMD Ryzen AI 300).
# Filesystems are left out on purpose: they are declared in ./disko.nix.
{ config, lib, modulesPath, nixos-hardware, ... }:

{
  imports = [
    (modulesPath + "/installer/scan/not-detected.nix")
    # obsidian-laptop imported this from the old flake for every host.
    nixos-hardware.nixosModules.framework-amd-ai-300-series
  ];

  boot.initrd.availableKernelModules = [ "nvme" "xhci_pci" "thunderbolt" "usb_storage" "sd_mod" ];
  boot.initrd.kernelModules = [ ];
  boot.kernelModules = [ "kvm-amd" ];
  boot.extraModulePackages = [ ];

  swapDevices = [ ];

  networking.useDHCP = lib.mkDefault true;

  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
  hardware.cpu.amd.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;
}
