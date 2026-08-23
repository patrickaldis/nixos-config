{ pkgs, ... }:
{
  programs.fish = {
    enable = true;
    interactiveShellInit = /* fish */ ''

      fish_default_key_bindings

      ${pkgs.any-nix-shell}/bin/any-nix-shell fish --info-right | source

      bind \b backward-kill-word
      bind \e\[3\;5~ kill-word

      direnv hook fish | source

      zoxide init fish | source

      alias cd="z"
      alias lg="lazygit"
    '';
  };
}
