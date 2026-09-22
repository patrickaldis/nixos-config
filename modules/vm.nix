{
  virtualisation.vmVariant = {

    virtualisation.diskImage = null;
    virtualisation.tpm.enable = true;
    virtualisation.sharedDirectories.payload = {
      source = ''"''${PAYLOAD_DIR:?}"'';
      target = "/payload";
      securityModel = "mapped-xattr";
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
