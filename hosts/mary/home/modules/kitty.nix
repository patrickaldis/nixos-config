{ theme, ... }:
{
  programs.kitty = {
    enable = true;
    font = {
      name = "JetBrainsMono Nerd Font";
      size = 10;
    };
    keybindings = {
        "ctrl+shift+equal" = "change_font_size current +1.0";
        "ctrl+shift+minus" = "change_font_size current -1.0";
    };
    settings = {
      "confirm_os_window_close" = 0;
      "touch_scroll_multiplier" = 5;
    };
    themeFile = "Catppuccin-Mocha";
  };
}
