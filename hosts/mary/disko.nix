{ disko, ... }:
{
  imports = [ disko.nixosModules.disko ];

  disko.devices = {
    disk = {
      main = {
        type = "disk";
        device = "/dev/disk/by-id/nvme-WD_BLACK_SN850X_2000GB_25132L801158";
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
                mountOptions = [
                  "fmask=0022"
                  "dmask=0022"
                ];
              };
            };
            luks = {
              size = "100%";
              content = {
                type = "luks";
                name = "root";
                # No passwordFile/keyFile: disko prompts for the passphrase
                # interactively during `disko --mode disko`.
                settings.allowDiscards = true;
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
        options = {
          ashift = "12";
          autotrim = "on";
        };
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
