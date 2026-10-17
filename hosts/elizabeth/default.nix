{
  modules = [
    ./shared.nix
    ./hardware-configuration.nix
    ./disko.nix
    ./users.nix

    ({ import-tree, home-manager, ... }: {
      imports = [
        home-manager.nixosModules.default
      ];

      home-manager.useGlobalPkgs = true;
      home-manager.users.patrick = (import-tree ./home);
    })
    {
      system.stateVersion = "26.11";
    }
    {
      age.init = pl: /* sh */ ''
        install -D -m 600 ${pl}/elizabeth /etc/ssh/ssh_host_ed25519_key
        install -D -m 644 ${pl}/elizabeth.pub /etc/ssh/ssh_host_ed25519_key.pub
      '';
    }
  ];
}
