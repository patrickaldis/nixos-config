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

      age.initUser = pl: /* sh */ ''
        install -d -m 700 -o patrick -g users /home/patrick/.ssh
        install -m 600 -o patrick -g users ${pl}/patrick_elizabeth /home/patrick/.ssh/id_ed25519
        install -m 644 -o patrick -g users ${pl}/patrick_elizabeth.pub /home/patrick/.ssh/id_ed25519.pub
      '';
    }
  ];
}
