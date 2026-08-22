{
  modules = [

    ({agenix, ...}: { imports = [agenix.nixosModules.default];})

    ({system, ...}:{
      nixpkgs.hostPlatform = system;
      system.stateVersion = "26.05";
      boot.loader.systemd-boot.enable = true;
      boot.loader.efi.canTouchEfiVariables = true;

      # enable flakes
      nix.settings.experimental-features = ["nix-command" "flakes"];
    })

    ({import-tree, ...}: {imports = [(import-tree ./import-tree)];})
  ];
}
