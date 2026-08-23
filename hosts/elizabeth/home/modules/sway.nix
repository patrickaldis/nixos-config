{
  config,
  lib,
  pkgs,
  theme,
  inputs,
  ...
}:

# NOTE - You must enable the NixOS option programs.sway.enable
# NOTE - Take a look at the default option file:
# https://github.com/nix-community/home-manager/blob/master/modules/services/window-managers/i3-sway/sway.nix
{

  wayland.windowManager.sway = {
    enable = true;
    systemd = {
      enable = true;
      xdgAutostart = true;
      variables = [ "--all" ];
    };
    package = pkgs.swayfx;
    extraConfig =
      let
        mod = config.wayland.windowManager.sway.config.modifier;
      in
      /* swayconfig */ '' 
      font pango:JetBrainsMono Nerd Font 10.000000 floating_modifier Mod1 default_border pixel 2 default_floating_border normal 2 hide_edge_borders none focus_wrapping no focus_follows_mouse yes focus_on_window_activation smart mouse_warping container workspace_layout default workspace_auto_back_and_forth no
      client.focused #606697 #8f97e8 #ffffff #bd8fe8 #8f97e8
      client.focused_inactive #606697 #606697 #ffffff #606697 #484d6f
      client.unfocused #606697 #484d6f #ffffff #606697 #484d6f
      client.urgent #2f343a #900000 #ffffff #900000 #900000
      client.placeholder #000000 #0c0c0c #ffffff #000000 #0c0c0c
      client.background #ffffff

      bindsym Ctrl+Print exec ${pkgs.sway-contrib.grimshot}/bin/grimshot copy window
      bindsym Mod1+0 workspace number 10
      bindsym Mod1+1 workspace number 1
      bindsym Mod1+2 workspace number 2
      bindsym Mod1+3 workspace number 3
      bindsym Mod1+4 workspace number 4
      bindsym Mod1+5 workspace number 5
      bindsym Mod1+6 workspace number 6
      bindsym Mod1+7 workspace number 7
      bindsym Mod1+8 workspace number 8
      bindsym Mod1+9 workspace number 9
      bindsym Mod1+Ctrl+j workspace next
      bindsym Mod1+Ctrl+k workspace prev
      bindsym Mod1+Ctrl+left exec ${pkgs.playerctl}/bin/playerctl previous
      bindsym Mod1+Ctrl+right exec ${pkgs.playerctl}/bin/playerctl next
      bindsym Mod1+Down focus down
      bindsym Mod1+Left focus left
      bindsym Mod1+Print exec ${pkgs.sway-contrib.grimshot}/bin/grimshot copy area
      bindsym Mod1+Return exec kitty
      bindsym Mod1+Right focus right
      bindsym Mod1+Shift+0 move container to workspace number 10
      bindsym Mod1+Shift+1 move container to workspace number 1
      bindsym Mod1+Shift+2 move container to workspace number 2
      bindsym Mod1+Shift+3 move container to workspace number 3
      bindsym Mod1+Shift+4 move container to workspace number 4
      bindsym Mod1+Shift+5 move container to workspace number 5
      bindsym Mod1+Shift+6 move container to workspace number 6
      bindsym Mod1+Shift+7 move container to workspace number 7
      bindsym Mod1+Shift+8 move container to workspace number 8
      bindsym Mod1+Shift+9 move container to workspace number 9
      bindsym Mod1+Shift+Down move down
      bindsym Mod1+Shift+Left move left
      bindsym Mod1+Shift+Right move right
      bindsym Mod1+Shift+Up move up
      bindsym Mod1+Shift+c kill
      bindsym Mod1+Shift+d exec neovide
      bindsym Mod1+Shift+e exec swaynag -t warning -m 'You pressed the exit shortcut. Do you really want to exit sway? This will end your Wayland session.' -b 'Yes, exit sway' 'swaymsg exit'
      bindsym Mod1+Shift+f exec nautilus
      bindsym Mod1+Shift+h move left
      bindsym Mod1+Shift+j move down
      bindsym Mod1+Shift+k move up
      bindsym Mod1+Shift+l move right
      bindsym Mod1+Shift+minus move scratchpad
      bindsym Mod1+Shift+q mode 'disable'
      bindsym Mod1+Shift+return exec kitty
      bindsym Mod1+Shift+s exec firefox
      bindsym Mod1+Up focus up
      bindsym Mod1+a focus parent
      bindsym Mod1+b splith
      bindsym Mod1+e layout toggle split
      bindsym Mod1+f fullscreen toggle
      bindsym Mod1+h focus left
      bindsym Mod1+j focus down
      bindsym Mod1+k focus up
      bindsym Mod1+l focus right
      bindsym Mod1+minus scratchpad show
      bindsym Mod1+n split none
      bindsym Mod1+p exec ${pkgs.walker}/bin/walker
      bindsym Mod1+q layout stacking
      bindsym Mod1+r mode resize2
      bindsym Mod1+s focus child
      bindsym Mod1+space exec pkill -SIGUSR1 '^.waybar-wrapped$'
      bindsym Mod1+t floating toggle
      bindsym Mod1+v splitv
      bindsym Mod1+w layout tabbed
      bindsym Print exec ${pkgs.sway-contrib.grimshot}/bin/grimshot copy screen
      bindsym Shift+Ctrl+Print exec ${pkgs.sway-contrib.grimshot}/bin/grimshot save area $HOME/Pictures/Screenshots/$(date -d 'today' +'%Y%m%d%H%M').png
      bindsym Shift+Mod1+Print exec ${pkgs.sway-contrib.grimshot}/bin/grimshot save area $HOME/Pictures/Screenshots/$(date -d 'today' +'%Y%m%d%H%M').png
      bindsym Shift+Print exec ${pkgs.sway-contrib.grimshot}/bin/grimshot save screen $HOME/Pictures/Screenshots/$(date -d 'today' +'%Y%m%d%H%M').png
      bindsym XF86AudioLowerVolume exec swayosd-client --output-volume lower
      bindsym XF86AudioMute exec swayosd-client --output-volume mute-toggle
      bindsym XF86AudioNext exec swayosd-client --playerctl next
      bindsym XF86AudioPlay exec swayosd-client --playerctl play-pause
      bindsym XF86AudioPrev exec swayosd-client --playerctl previous
      bindsym XF86AudioRaiseVolume exec swayosd-client --output-volume raise
      bindsym XF86MonBrightnessDown exec swayosd-client --brightness -10
      bindsym XF86MonBrightnessUp exec swayosd-client --brightness +10

      input "type:keyboard" {
        repeat_delay 300
        xkb_layout gb
        xkb_options caps:escape,compose:ralt
      }

      input "type:pointer" {
        natural_scroll disabled
      }

      input "type:touchpad" {
        middle_emulation enabled
        natural_scroll enabled
        scroll_factor 0.2
        tap enabled
      }

      input "1739:31251:DLL07BE:01_06CB:7A13_Touchpad" {
        accel_profile adaptive
        pointer_accel 0.1
        scroll_factor 0.3
      }

      output "DP-1" {
        mode 2560x1440@164.802Hz
      }

      output "eDP-1" {
        scale 2
      }

      seat "*" {
        xcursor_theme Adwaita
      }

      mode "resize" {
        bindsym Down resize grow height 10 px
        bindsym Escape mode default
        bindsym Left resize shrink width 10 px
        bindsym Return mode default
        bindsym Right resize grow width 10 px
        bindsym Up resize shrink height 10 px
        bindsym h resize shrink width 10 px
        bindsym j resize grow height 10 px
        bindsym k resize shrink height 10 px
        bindsym l resize grow width 10 px
      }

      bar {
        font pango:monospace 8.000000
        swaybar_command waybar
      }

      for_window [app_id="ranger"] floating enable
      for_window [app_id="openrgb"] floating enable
      for_window [app_id="blueberry.py"] floating enable
      for_window [app_id="polychromatic"] floating enable
      for_window [app_id="pavucontrol"] floating enable
      for_window [app_id="nm-connection-editor"] floating enable
      for_window [app_id=".blueman-manager-wrapped"] floating enable
      for_window [app_id="org.gnome.Nautilus"] floating enable
      for_window [app_id="lutris"] floating enable
      for_window [app_id="com.usebottles.bottles"] floating enable
      for_window [app_id="org.gnome.baobab"] floating enable
      for_window [app_id="seahorse"] floating enable
      for_window [app_id="fr.handbrake.ghb"] floating enable
      for_window [app_id="org.kde.kdeconnect-indicator"] floating enable
      for_window [app_id="wdisplays"] floating enable
      for_window [app_id="com.github.wwmm.easyeffects"] floating enable
      for_window [app_id="deluge"] floating enable
      for_window [app_id="google-chat-wrapper"] floating enable
      for_window [app_id="linear-wrapper"] floating enable
      for_window [app_id="Zulip"] floating enable
      for_window [class=".polychromatic-controller-wrapped"] floating enable
      for_window [class="battle.net.exe"] floating enable
      for_window [class=".*"] inhibit_idle fullscreen
      for_window [app_id="ranger"] resize set height 40ppt
      for_window [app_id="ranger"] resize set width 40ppt
      exec swaync

      exec ${pkgs.xfce.xfce4-power-manager}/bin/xfce4-power-manager --daemon

      exec ${pkgs.wluma}/bin/wluma

      exec ${pkgs.wlsunset}/bin/wlsunset -t 4000 -T 6500

      exec ${pkgs.walker}/bin/walker --gapplication-service

      exec ${pkgs.lxqt.lxqt-policykit}/bin/lxqt-policykit-agent

      mode 'disable' {
        bindsym Mod1+Shift+q mode "default"
      }

      mode 'resize2' {
        bindsym space mode "default"
        bindsym escape mode "default"
        bindsym return mode "default"
        bindsym Mod1+r mode "default"

        bindsym h resize shrink right 10 ppt
        bindsym l resize grow right 10 ppt
        bindsym j resize grow down 10 ppt
        bindsym k resize shrink down 10 ppt
      }

      animation_duration_ms 200

      bindgesture swipe:3:right workspace prev
      bindgesture swipe:3:left workspace next

      bindgesture swipe:4:up move scratchpad
      bindgesture swipe:4:down [floating] scratchpad show

      bindgesture pinch:inward floating enable
      bindgesture pinch:outward floating disable
      bindsym --border button2 kill
      workspace 1
        mode 'disable' {
          bindsym ${mod}+Shift+q mode "default"
        }

        mode 'resize2' {
          bindsym space mode "default"
          bindsym escape mode "default"
          bindsym return mode "default"
          bindsym ${mod}+r mode "default"

          bindsym h resize shrink right 10 ppt
          bindsym l resize grow right 10 ppt
          bindsym j resize grow down 10 ppt
          bindsym k resize shrink down 10 ppt
        }

        animation_duration_ms 200

        bindgesture swipe:3:right workspace prev
        bindgesture swipe:3:left workspace next

        bindgesture swipe:4:up move scratchpad
        bindgesture swipe:4:down [floating] scratchpad show

        bindgesture pinch:inward floating enable
        bindgesture pinch:outward floating disable
        bindsym --border button2 kill
        workspace 1
      '';
  };
}
