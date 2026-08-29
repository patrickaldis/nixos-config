{disko, ...}:{
  imports = [disko.nixosModules.disko];

  disko.devices = {
    disk = {
      main = {
        imageSize = "10G";
        device = "/dev/disk/by-id/nvme-AirDisk_512GB_SSD_QFQ684W005931P110N";
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
