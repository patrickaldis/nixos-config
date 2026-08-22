{disko, ...}:{
  imports = [disko.nixosModules.disko];

  disko.devices = {
    disk = {
      main = {
        imageSize = "10G";
        device = "/dev/disk/by-id/ata-SK_hynix_SC311_SATA_256GB_MS82N176810802R0S";
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
  # {                                                        
  #   disko.devices = {                                      
  #     disk = {                                             
  #       main = {                                           
  #         type = "disk";                                   
  #         device = "/dev/nvme0n1";                         
  #         content = {                                      
  #           type = "gpt";                                  
  #           partitions = {                                 
  #             ESP = {                                      
  #               size = "2G";                               
  #               type = "EF00";                             
  #               content = {                                
  #                 type = "filesystem";                     
  #                 format = "vfat";                         
  #                 mountpoint = "/boot";                    
  #               };                                         
  #             };                                           
  #             luks = {                                     
  #               size = "100%";                             
  #               content = {                                
  #                 type = "luks";                           
  #                 name = "root";                           
  #                 settings = {                             
  #                   allowDiscards = true;                  
  #                 };                                       
  #                 passwordFile = "/tmp/disk-password"; # or
  #  use interactive prompt                                  
  #                 content = {                              
  #                   type = "zfs";                          
  #                   pool = "mainpool";                     
  #                 };                                       
  #               };                                         
  #             };                                           
  #           };                                             
  #         };                                               
  #       };                                                 
  #     };                                                   
  #     zpool = {                                            
  #       mainpool = {                                       
  #         type = "zpool";                                  
  #         rootFsOptions = {                                
  #           compression = "zstd";                          
  #           atime = "off";                                 
  #           xattr = "sa";                                  
  #           mountpoint = "legacy";                         
  #         };                                               
  #         datasets = {                                     
  #           rootfs = {                                     
  #             type = "zfs_fs";                             
  #             mountpoint = "/";                            
  #             options.mountpoint = "legacy";               
  #           };                                             
  #         };                                               
  #       };                                                 
  #     };                                                   
  #   };                                                     
  # }
