{ virglrenderer, ... }: {
  nix.settings = {
    substituters = [
      "https://hyprland.cachix.org"
      "https://nix-community.cachix.org"
      "https://cache.iog.io"
      "https://helix.cachix.org"
      "https://georgefst.cachix.org"
      "https://cache.zw3rk.com"
    ];
    trusted-public-keys = [
      "hyprland.cachix.org-1:a7pgxzMz7+chwVL3/pzj6jIBMioiJM7ypFP8PwtkuGc="
      "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
      "hydra.iohk.io:f/Ea+s+dFdN+3Y/G+FDgSq+a5NEWhJGzdjvKNGv0/EQ="
      "helix.cachix.org-1:ejp9KQpR1FBI2onstMQ34yogDm4OgU2ru6lIwPvuCVs="
      "georgefst.cachix.org-1:vuSIhlomQ+gIylNOJUXEnzRhtvYvHzUrpT/ezaN0kX8="
      "loony-tools:pr9m4BkM/5/eSTZlkQyRt57Jz7OMBxNSUiMC4FkcNfk="
    ];
    experimental-features = [
      "nix-command"
      "flakes"
    ];
  };
  nixpkgs.config.allowUnfree = true;
  nixpkgs.overlays = [
    (self: super: {
      # fix upside-down cursor on qemu
      virglrenderer = (super.virglrenderer.override { vulkanSupport = false; }).overrideAttrs (old: {
        version = "unstable";
        src = virglrenderer;
        patches = [ ];
      });
      qemu = super.qemu.override { virglrenderer = self.virglrenderer; };
    })
  ];
}
