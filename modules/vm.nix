{ lib, ... }: {
  virtualisation.vmVariant = {

    # Add '/payload' fileesystem to load private keys to vm
    fileSystems."/payload" = lib.mkOverride 10 {
      device = "shared_tag";
      fsType = "9p";
      options = [
        "trans=virtio"
        "version=9p2000.L"
        "nofail"
      ];
    };

    # VM Settings
    virtualisation.memorySize = 4096;
    virtualisation.cores = 8;
    virtualisation.resolution = {
      x = 1920;
      y = 1080;
    };
    virtualisation.msize = 65536;
    virtualisation.qemu.options = [
      "-device virtio-vga-gl"
      "-display gtk,gl=on"
    ];
  };
}
