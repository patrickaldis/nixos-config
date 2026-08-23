{disko, ...}:{
  imports = [disko.nixosModules.disko];

  disko.devices = {
    disk = {
      main = {
        imageSize = "10G";
        device = "/dev/disk/by-id/nvme-THNSN5512GPUK_NVMe_TOSHIBA_512GB_47OB51CBKSJU";
        type = "disk";
        content = {
          type = "gpt";
          partitions = {
            ESP = {
              type = "EF00";
              size = "500M";
              content = {
                type = "filesystem";
                format = "vfat";
                mountpoint = "/boot";
                mountOptions = [ "umask=0077" ];
              };
            };
            root = {
              size = "100%";
              content = {
                type = "filesystem";
                format = "ext4";
                mountpoint = "/";
              };
            };
          };
        };
      };
    };
  };
}
