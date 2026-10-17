{ lib, config, ... }:
{
  virtualisation.vmVariant = {

    # hosts/*/default.nix import installer/cd-dvd/iso-image.nix, which
    # defines its own register-nix-paths.service (loading a
    # /nix/store/nix-path-registration baked into a real ISO's squashfs).
    # That gets merged with qemu-vm.nix's own register-nix-paths.service
    # (which reads the registration file from the `regInfo=` kernel param
    # instead), and the merged script's ISO half fails under `set -e` since
    # no such file exists when /nix/store is shared straight from the host.
    # Override back to just the VM-correct behaviour here.
    systemd.services.register-nix-paths.script = lib.mkVMOverride ''
      if [[ "$(cat /proc/cmdline)" =~ regInfo=([^ ]*) ]]; then
        ${lib.getExe' config.nix.package.out "nix-store"} --load-db < "''${BASH_REMATCH[1]}"
      fi
    '';

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
