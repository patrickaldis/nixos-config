{ lib, options, config, ... }:

let machines = {
  "fremden" = {
    hostName = "ministryofdevelopment";
    domain = "dyndns.org";
    system = "x86_64-darwin";
    sshPort = 10200;
  };
  "reboot" = {
    system = "x86_64-linux";
    sshPort = 8099;
  };
  "metis" = {
    system = "x86_64-linux";
    sshPort = 9099;
    cachePort = 9050;
    cachePublicKey = "obsidian.webhop.org-2:1SpmKp9kXPQsZMka5l4NeSLyZEDd2RS9q03Q+VuIIj8=";
  };
  "eris" = {
    system = "x86_64-linux";
    sshPort = 9199;
    cachePort = 9150;
    cachePublicKey ="eris-1:LTvJs7Xlr5rrFMchM9SoY4Dunbc4wV09Dz/JbiG0Xp0=";
  };
  "khaldun" = {
    system = "x86_64-linux";
    sshPort = 9299;
  };
  "icarus" = {
    system = "x86_64-darwin";
    sshPort = 9399;
    supportedFeatures = ["big-parallel"];
  };
  "odysseus" = {
    system = "x86_64-linux";
    sshPort = 9499;
  };
  "demothenes" = {
    system = "x86_64-linux";
    sshPort = 9699;
  };
  "zigpolymath" = {
    system = "x86_64-linux";
    sshPort = 9799;
  };
  "bolon" = {
    system = "x86_64-linux";
    sshPort = 9899;
  };
  "hestia" = {
    system = "x86_64-linux";
    sshPort = 9999;
  };
  "priam" = {
    system = "x86_64-linux";
    sshPort = 10399;
    trustedCiMachine = true;
  };
  "metella" = {
    system = "x86_64-linux";
    sshPort = 11099;
  };
  "minotaur" = {
    system = "x86_64-linux";
    sshPort = 10099;
  };
  "fileserver" = {
    system = "x86_64-linux";
    sshPort = 10699;
    trustedCiMachine = true;
    cachePort = 8950;
    cachePublicKey = "obsidian.webhop.org-1:7wdOogi+TMjCYxCePRRXRQZ8sfjTV4trYA+WtzDmyck=";
  };
  "macos-ny-1" = {
    system = "x86_64-darwin";
    sshPort = 12999;
    sshPublicKey = "ecdsa-sha2-nistp256 AAAAE2VjZHNhLXNoYTItbmlzdHAyNTYAAAAIbmlzdHAyNTYAAABBBCXybRhilr5Dv1c7qfOLzK8PGDnRp6hL9g+lQwVVPvUvoOeL3lzBqXgv+pnNhlvBjB3NG8tcaXEDNEbM/OrmM4c=";
    supportedFeatures = ["big-parallel"];
    trustedCiMachine = true;
    maxJobs = 6;
  };
  "macos-ny-2" = {
    system = "x86_64-darwin";
    sshPort = 13099;
    sshPublicKey = "ecdsa-sha2-nistp256 AAAAE2VjZHNhLXNoYTItbmlzdHAyNTYAAAAIbmlzdHAyNTYAAABBBM5gBpf6aYXfhL6j7TwxkB4RbpAwYJa1+Nc/TIo8y6hcXjmLd1QxQUqIp7NWXJzNGDXC1EHSoYeD/Ddr7lDrQ8o=";
    supportedFeatures = ["big-parallel"];
    trustedCiMachine = true;
    maxJobs = 6;
  };

  "build-ny-linux-0" = {
    system = "x86_64-linux";
    sshPublicKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIASHicYwHWI5GgJANxCZlukbQGZBo6492vhlyq+4vKO3";
    trustedCiMachine = true;
    supportedFeatures = [ "big-parallel" "kvm" "nixos-test" "benchmark" ];
    maxJobs = 15;
  };
  "tiresias" = {
    system = "x86_64-linux";
    sshPort = 8999;
    sshPublicKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIOTs18JDbGifro7iwswhN+tLwYZDQhlGhS0Ik6Pr3k4v";
    trustedCiMachine = true;
    supportedFeatures = [ "big-parallel" "kvm" "nixos-test" "benchmark" ];
    maxJobs = 11;
  };

};

inherit (lib) mkOption types;

in

{
  options = {
    obsidian = {
      iThinkIAmATrustedCiMachine = mkOption {
        description = ''
          Indicates that the machine thinks they are part of the exclusive trusted CI
          machine club.

          Machines that consider themselves a member will only use known members (per
          obsidian.machines.<name>.trustedCiMachine) as binary caches or remote builders,
          so as not to pollute their store with untrusted binaries. They will happily
          serve binaries to anyone, but only act as a remote builder for other members, so
          since remote builder users can upload binaries.

          Machines that don't consider themselves a member will use CI club machines as
          binary caches, because those binaries are good, but they won't use them as
          remote builders because they know their requests would be declined.

          In short:

          +---------------+--------------------------------------+
          | Machine Class | Uses as binary cache                 |
          +---------------+------------------------+-------------+
          |               | CI machine             | Reg machine |
          | CI Machine    | X                      |             |
          | Reg machine   | X                      | X           |
          +---------------+------------------------+-------------+

          +---------------+--------------------------------------+
          | Machine Class | Uses as remote builder               |
          +---------------+------------------------+-------------+
          |               | CI machine             | Reg machine |
          | CI Machine    | X                      |             |
          | Reg machine   |                        | X*          |
          +---------------+------------------------+-------------+

          * Regular machine remote building is done with an untrusted proxy user on the
          other machine, with the idea that built binaries are never *up*loaded to the
          user for security reasons. But this currently will result in no capability to
          build whatsoever, so this is disabled to avoid slow timeouts.
        '';
        type = types.bool;
        default = machines.${config.networking.hostName}.trustedCiMachine or false;
      };

      alwaysBehindNat = mkOption {
        description = ''
          This machine is always behind the NAT, so it should never access
          machines via obsidian.webhop.org.
        '';
        type = types.bool;
        default = machines ? ${config.networking.hostName};
      };

      machines = mkOption {
        description = "Information on machines controlled by Obsidian Systems for use in connecting to them";
        type = lib.types.attrsOf (lib.types.submodule ({ options', config', ... }: {
          # TODO: Leverage https://github.com/NixOS/nixpkgs/pull/83104 once we only support releases with it. At the time of writing it is only present in the 20.09 branch
          options = {
            sshPort = mkOption {
              type = types.nullOr types.int;
              description = ''
                Specifies on which port the SSH daemon listens.
              '';
              default = null;
            };
            sshPublicKey = mkOption {
              type = types.nullOr types.str;
              description = ''
                Specifies the host public key for the machine, as plain DNS is
                not a trustworthy source of machine identity.
              '';
              default = null;
            };
            hostName = options.networking.hostName // {
              default = "obsidian";
            };
            domain = options.networking.domain // {
              default = "webhop.org";
            };
            cachePort = mkOption {
              type = types.nullOr types.int;
              default = null;
            };
            cachePublicKey = mkOption {
              type = types.nullOr types.str;
              default = null;
            };
            system = mkOption {
              type = types.str;
            };
            maxJobs = mkOption {
              type = types.int;
              default = 1;
            };
            speedFactor = mkOption {
              type = types.int;
              default = 1;
            };
            supportedFeatures = mkOption {
              type = types.listOf types.str;
              default = [];
            };
            mandatoryFeatures = mkOption {
              type = types.listOf types.str;
              default = [];
            };
            trustedCiMachine = mkOption {
              description = "See obsidian.iThinkIAmATrustedCiMachine";
              type = types.bool;
              default = false;
            };
          };
        }));
        default = machines;
      };
    };
  };

  config = let
    forEachMachineList = f: lib.concatLists (lib.mapAttrsToList f config.obsidian.machines);
    forEachMachineMap = f: builtins.listToAttrs (forEachMachineList f);
  in {
    programs.ssh = {
      extraConfig = builtins.concatStringsSep "\n"
        (forEachMachineList (name: { sshPort, hostName, domain, ... }:
          lib.optional (sshPort != null) ''
            Host ${name}-remote
            HostName ${hostName}.${domain}
            Port ${toString sshPort}
          ''));
      knownHosts = forEachMachineMap (name: { sshPublicKey, sshPort, hostName, domain, ... }:
        lib.optional (sshPublicKey != null) {
          inherit name;
          value = {
            # TODO teach upstream module about port
            hostNames = [ "${name}.office" ]
              ++ lib.optional (!config.obsidian.alwaysBehindNat && sshPort != null)
                              "[${hostName}.{domain}]:${toString sshPort}";
            publicKey = sshPublicKey;
          };
        });
    };
    nix = {
      # TODO use forEachMachineMap after nixpkgs is updated to use `loaOf`
      buildMachines = forEachMachineList (name: info: let
        common = {
          sshUser =
            if config.obsidian.iThinkIAmATrustedCiMachine
            then "nix_trusted_proxy"
            else "nix_untrusted_proxy";
          sshKey = "/etc/nixos/obsidian-build-remote";
          inherit (info)
            system maxJobs speedFactor supportedFeatures mandatoryFeatures;
        };
      in lib.optionals
        # TODO: reenable remote building with an untrustd user by switching to:
        # (config.obsidian.iThinkIAmATrustedCiMachine == info.trustedCiMachine)
        ((config.obsidian.iThinkIAmATrustedCiMachine && info.trustedCiMachine)
         && info.sshPublicKey != null)
        ([ (common // { hostName = "${name}.office"; }) ]
         ++ lib.optional (!config.obsidian.alwaysBehindNat && info.sshPort != null)
                         (common // { hostName = "${name}-remote"; })));
      settings = {
        substituters = forEachMachineList (_: { hostName, domain, cachePort, trustedCiMachine, ... }:
          lib.optional
            ((config.obsidian.iThinkIAmATrustedCiMachine -> trustedCiMachine) && (cachePort != null))
            "http://${hostName}.${domain}:${toString cachePort}");
        trusted-public-keys = forEachMachineList (_: { cachePublicKey, trustedCiMachine, ... }:
          lib.optional
            ((config.obsidian.iThinkIAmATrustedCiMachine -> trustedCiMachine) && (cachePublicKey != null))
            cachePublicKey);
      };
    };
  };
}
