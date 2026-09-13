{lib, ...}:{
  fileSystems."/payload" = lib.mkOverride 10 {
    device = "shared_tag";
    fsType = "9p";
    options = [
      "trans=virtio"
      "version=9p2000.L"
      "nofail"
    ];
  };
}
