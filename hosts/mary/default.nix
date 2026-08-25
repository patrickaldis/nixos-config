{
  modules = [
    ./shared.nix
    ./hardware-configuration.nix
    ./disko.nix

    ({import-tree, home-manager, ...}:{
      imports = [
        home-manager.nixosModules.default
      ];

      home-manager.useGlobalPkgs = true;
      home-manager.users.patrick = (import-tree ./home);
    })
  ];
}
