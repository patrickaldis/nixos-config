{
  config,
  lib,
  pkgs,
  home-manager,
  audiomenu,
  system,
  ...
}:
let
  cfg = config.desktop.sway;

  theme = {
    secondary = "#bd8fe8";
    neutral = "#8f97e8";
    background'' = "#606697";
    background' = "#484d6f";
    danger = "#e06c75";
  };

  # swaylock wants bare hex (no leading '#').
  hex = lib.removePrefix "#";

  grimshot = "${pkgs.sway-contrib.grimshot}/bin/grimshot";
  screenshotPath = "$HOME/Pictures/Screenshots/$(date -d 'today' +'%Y%m%d%H%M').png";

  homeModule =
    { config, ... }:
    {
      home.packages = [
        pkgs.walker
        pkgs.elephant
      ];

      # Partial config: walker merges this over its built-in defaults.
      # Without force_keyboard_focus walker requests OnDemand keyboard
      # interactivity, and sway doesn't give it focus when it opens.
      xdg.configFile."walker/config.toml".text = ''
        force_keyboard_focus = true
      '';

      # walker (v2) is only a frontend: elephant provides the results.
      systemd.user.services.elephant = {
        Unit = {
          Description = "Elephant";
          After = [ "graphical-session.target" ];
          PartOf = [ "graphical-session.target" ];
        };
        Service = {
          Type = "simple";
          ExecStart = "${pkgs.elephant}/bin/elephant";
          Restart = "on-failure";
        };
        Install.WantedBy = [ "graphical-session.target" ];
      };

      programs.swaylock = {
        enable = true;
        package = pkgs.swaylock-effects;
        settings = {
          screenshots = true;
          effect-blur = "7x5";
          effect-vignette = "0.5:0.5";
          clock = true;
          timestr = "%H:%M";
          datestr = "%A, %d %B";

          indicator = true;
          indicator-radius = 120;
          indicator-thickness = 10;

          font = "JetBrainsMono Nerd Font";
          font-size = 32;

          ring-color = hex theme.neutral;
          ring-ver-color = hex theme.secondary;
          ring-wrong-color = hex theme.danger;
          ring-clear-color = hex theme.background';

          inside-color = "484d6fcc";
          inside-ver-color = "484d6fcc";
          inside-wrong-color = "484d6fcc";
          inside-clear-color = "484d6fcc";

          line-color = "00000000";
          separator-color = "00000000";

          text-color = "ffffff";
          text-ver-color = "ffffff";
          text-wrong-color = "ffffff";
          text-clear-color = "ffffff";

          key-hl-color = hex theme.secondary;
          bs-hl-color = hex theme.danger;

          ignore-empty-password = true;
          grace = 2;
          fade-in = 0.2;
        };
      };

      # Locks on suspend/lid-close via logind's sleep signal. Needed because
      # xfce4-power-manager's own "lock on suspend" only knows how to drive
      # X11 screensavers (xflock4) and fails with "none of the screen lock
      # tools ran successfully" on a Wayland/sway session; that feature is
      # disabled below in favour of this.
      services.swayidle = {
        enable = true;
        events = {
          before-sleep = "${pkgs.swaylock}/bin/swaylock -f";
          lock = "${pkgs.swaylock}/bin/swaylock -f";
        };
      };

      wayland.windowManager.sway = {
        enable = true;
        # sway itself comes from the NixOS programs.sway module below.
        package = null;
        systemd = {
          enable = true;
          xdgAutostart = true;
          variables = [ "--all" ];
        };
        checkConfig = false;

        config = {
          terminal = "kitty";
          bars = [ { command = "waybar"; } ];
          focus.mouseWarping = "container";

          fonts = {
            names = [ "JetBrainsMono Nerd Font" ];
            size = 10.0;
          };

          window.titlebar = false;

          startup = [
            { command = "swaync"; }
            {
              command = "${pkgs.xfconf}/bin/xfconf-query -c xfce4-power-manager -p /xfce4-power-manager/lock-screen-suspend-hibernate -t bool -s false --create";
            }
            {
              # Without this, xfce4-power-manager handles the lid switch
              # itself (independently of logind's HandleLidSwitch) and tries
              # to lock via the legacy org.freedesktop.ScreenSaver interface,
              # which swaylock/swayidle don't implement -- producing "None of
              # the screen lock tools ran successfully". Deferring to logind
              # leaves locking to swayidle's before-sleep/lock hooks above.
              command = "${pkgs.xfconf}/bin/xfconf-query -c xfce4-power-manager -p /xfce4-power-manager/logind-handle-lid-switch -t bool -s true --create";
            }
            { command = "${pkgs.xfce4-power-manager}/bin/xfce4-power-manager --daemon"; }
            { command = "${pkgs.wluma}/bin/wluma"; }
            { command = "${pkgs.wlsunset}/bin/wlsunset -t 4000 -T 6500"; }
            { command = "${pkgs.walker}/bin/walker --gapplication-service"; }
            { command = "${pkgs.lxqt.lxqt-policykit}/bin/lxqt-policykit-agent"; }
          ];

          seat."*".xcursor_theme = "Adwaita";

          input = {
            "type:keyboard" = {
              xkb_layout = "gb";
              xkb_options = "caps:escape,compose:ralt";
              repeat_delay = "300";
            };
            "type:touchpad" = {
              natural_scroll = "enabled";
              tap = "enabled";
              middle_emulation = "enabled";
              scroll_factor = "0.2";
            };
            "type:pointer" = {
              natural_scroll = "disabled";
            };
            "1739:31251:DLL07BE:01_06CB:7A13_Touchpad" = {
              accel_profile = "adaptive";
              pointer_accel = "0.1";
              scroll_factor = "0.3";
            };
          };

          output = {
            eDP-1.scale = "2";
            DP-1.mode = "2560x1440@164.802Hz";
          };

          colors = {
            focused = {
              background = theme.neutral;
              border = theme.background'';
              childBorder = theme.neutral;
              indicator = theme.secondary;
              text = "#ffffff";
            };
            focusedInactive = {
              background = theme.background'';
              border = theme.background'';
              childBorder = theme.background';
              indicator = theme.background'';
              text = "#ffffff";
            };
            unfocused = {
              background = theme.background';
              border = theme.background'';
              childBorder = theme.background';
              indicator = theme.background'';
              text = "#ffffff";
            };
          };

          modifier = "Mod1";
          left = "h";
          right = "l";
          up = "k";
          down = "j";

          keybindings =
            let
              mod = config.wayland.windowManager.sway.config.modifier;
              leader = key: binds: lib.mapAttrs' (stem: action: lib.nameValuePair "${key}+${stem}" action) binds;
              exec = cmd: "exec ${cmd}";
              sway = cmd: cmd;
            in
            lib.mkOptionDefault (
              (leader mod (
                (leader "Shift" {
                  "space" = exec "${audiomenu.packages.${system}.audiomenu}/bin/audiomenu select-sink";
                  "return" = exec "kitty";
                  "c" = sway "kill";
                  "s" = exec "firefox";
                  "d" = exec "neovide";
                  "q" = sway "mode 'disable'";
                  "f" = exec "nautilus";
                })
                // (leader "Ctrl" {
                  "j" = sway "workspace next";
                  "k" = sway "workspace prev";
                  "right" = exec "${pkgs.playerctl}/bin/playerctl next";
                  "left" = exec "${pkgs.playerctl}/bin/playerctl previous";
                })
                // {
                  "q" = sway "layout stacking";
                  "r" = sway "mode resize2";
                  "n" = sway "split none";
                  "s" = sway "focus child";
                  "t" = sway "floating toggle";
                  "p" = exec "${pkgs.walker}/bin/walker";
                  "space" = exec "pkill -SIGUSR1 '^.waybar-wrapped$'";
                }
              ))
              // {
                "XF86MonBrightnessUp" = exec "swayosd-client --brightness +10";
                "XF86MonBrightnessDown" = exec "swayosd-client --brightness -10";
                "XF86AudioRaiseVolume" = exec "swayosd-client --output-volume raise";
                "XF86AudioLowerVolume" = exec "swayosd-client --output-volume lower";
                "XF86AudioMute" = exec "swayosd-client --output-volume mute-toggle";
                "XF86AudioNext" = exec "swayosd-client --playerctl next";
                "XF86AudioPrev" = exec "swayosd-client --playerctl previous";
                "XF86AudioPlay" = exec "swayosd-client --playerctl play-pause";
                "Print" = exec "${grimshot} copy screen";
                "${mod}+Print" = exec "${grimshot} copy area";
                "Ctrl+Print" = exec "${grimshot} copy window";
                "Shift+Print" = exec "${grimshot} save screen ${screenshotPath}";
                "Shift+${mod}+Print" = exec "${grimshot} save area ${screenshotPath}";
                "Shift+Ctrl+Print" = exec "${grimshot} save area ${screenshotPath}";
              }
            );

          floating.criteria = [
            { app_id = "ranger"; }
            { app_id = "openrgb"; }
            { app_id = "blueberry.py"; }
            { app_id = "polychromatic"; }
            { app_id = "pavucontrol"; }
            { app_id = "nm-connection-editor"; }
            { app_id = ".blueman-manager-wrapped"; }
            { app_id = "org.gnome.Nautilus"; }
            { app_id = "lutris"; }
            { app_id = "com.usebottles.bottles"; }
            { app_id = "org.gnome.baobab"; }
            { app_id = "seahorse"; }
            { app_id = "fr.handbrake.ghb"; }
            { app_id = "org.kde.kdeconnect-indicator"; }
            { app_id = "wdisplays"; }
            { app_id = "com.github.wwmm.easyeffects"; }
            { app_id = "deluge"; }
            { app_id = "Zulip"; }
            { class = ".polychromatic-controller-wrapped"; }
            { class = "battle.net.exe"; }
          ];

          window.commands = [
            {
              command = "inhibit_idle fullscreen";
              criteria.class = ".*";
            }
            {
              command = "resize set height 40ppt";
              criteria.app_id = "ranger";
            }
            {
              command = "resize set width 40ppt";
              criteria.app_id = "ranger";
            }
          ];
        };

        extraConfig =
          let
            mod = config.wayland.windowManager.sway.config.modifier;
          in
          /* swayconfig */ ''
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
    };
in
{
  # A path, so this is deduplicated against hosts that import it themselves.
  imports = [ home-manager.nixosModules.default ];

  options.desktop.sway = {
    enable = lib.mkEnableOption "the sway desktop (walker/elephant launcher, waybar, swaync, swayosd)";
    user = lib.mkOption {
      type = lib.types.str;
      default = "patrick";
      description = "User whose home-manager config receives the sway setup.";
    };
  };

  config = lib.mkIf cfg.enable {
    programs.sway = {
      enable = true;
      wrapperFeatures.gtk = true;
    };
    security.polkit.enable = true;

    home-manager.users.${cfg.user} = homeModule;
  };
}
