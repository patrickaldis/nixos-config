{
  modules = [
    ./shared.nix
    ./hardware-configuration.nix
    ./disko.nix
    ./gpg.nix

    # Work config: the vendored //obsidian tree, as hosts/obsidian-laptop
    # imported it in the old config.
    { obsidian.enable = true; }

    ({ import-tree, home-manager, ... }: {
      imports = [
        home-manager.nixosModules.default
      ];

      home-manager.useGlobalPkgs = true;
      home-manager.users.patrick = (import-tree ./home);
    })
    {
      system.stateVersion = "26.11";

      # ZFS root (see ./disko.nix). Carried over from obsidian-laptop so the
      # pool keeps the same host identity.
      networking.hostId = "f3160e21";
      services.zfs.autoScrub = {
        enable = true;
        interval = "monthly";
      };
    }
    # Local dev database, as on obsidian-laptop.
    ({ lib, pkgs, ... }: {
      services.postgresql = {
        enable = true;
        ensureDatabases = [ "playground" ];
        enableTCPIP = true;
        authentication = lib.mkOverride 10 ''
          #type database DBuser origin-address auth-method
          local all      all     trust
          host  all      all     127.0.0.1/32   trust
          host  all      all     ::1/128        trust
        '';
        initialScript = pkgs.writeText "backend-initScript" ''
          CREATE ROLE user WITH LOGIN PASSWORD 'password' CREATEDB;
          CREATE DATABASE testdb;
          GRANT ALL PRIVILEGES ON DATABASE testdb TO user;
        '';
      };
    })
    {
      age.init = pl: /* sh */ ''
        install -D -m 600 ${pl}/mary /etc/ssh/ssh_host_ed25519_key
        install -D -m 644 ${pl}/mary.pub /etc/ssh/ssh_host_ed25519_key.pub
        install -D -m 600 ${pl}/root_mary /root/.ssh/id_ed25519
        install -D -m 644 ${pl}/root_mary.pub /root/.ssh/id_ed25519.pub
      '';

      age.initUser = pl: /* sh */ ''
        install -d -m 700 -o patrick -g users /home/patrick/.ssh
        install -m 600 -o patrick -g users ${pl}/patrick_mary /home/patrick/.ssh/id_ed25519
        install -m 644 -o patrick -g users ${pl}/patrick_mary.pub /home/patrick/.ssh/id_ed25519.pub
      '';
    }
  ];
}
