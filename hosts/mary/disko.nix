{ disko, ... }: {
  imports = [ disko.nixosModules.disko ];

  disko.devices = {
    disk = {
      main = {
        type = "disk";
        device = "/dev/nvme0n1";
        content = {
          type = "gpt";
          partitions = {
            ESP = {
              size = "2G";
              type = "EF00";
              content = {
                type = "filesystem";
                format = "vfat";
                mountpoint = "/boot";
              };
            };
            luks = {
              size = "100%";
              content = {
                type = "luks";
                name = "root";
                settings = {
                  allowDiscards = true;
                };
                passwordFile = "/tmp/disk-password"; # or use interactive prompt
                content = {
                  type = "zfs";
                  pool = "mainpool";
                };
              };
            };
          };
        };
      };
    };
    zpool = {
      mainpool = {
        type = "zpool";
        rootFsOptions = {
          compression = "zstd";
          atime = "off";
          xattr = "sa";
          mountpoint = "legacy";
        };
        datasets = {
          rootfs = {
            type = "zfs_fs";
            mountpoint = "/";
            options.mountpoint = "legacy";
          };
        };
      };
    };
  };
}
