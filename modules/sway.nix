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

  # Microphone state. The gear key latches the mic open; Alt+Space is
  # push-to-talk while muted, and mutes outright (clearing the latch) while
  # live, so the loud key always wins. The latch file is what tells a release
  # whether it's ending a hold or has already been overridden.
  #
  # `status` reports what wireplumber actually says rather than what the latch
  # claims, so the waybar indicator stays honest if something else (e.g.
  # XF86AudioMicMute) changes the source behind our back.
  waybarMicSignal = 8;
  micctl = pkgs.writeShellApplication {
    name = "micctl";
    runtimeInputs = [
      pkgs.wireplumber
      pkgs.procps
      pkgs.swayosd
      pkgs.pipewire # pw-dump
      pkgs.jq
    ];
    text = ''
      latch="''${XDG_RUNTIME_DIR:-/tmp}/micctl.latch"
      src='@DEFAULT_AUDIO_SOURCE@'

      # interval: "once" + signal in waybar, so the indicator only re-reads
      # when we tell it to.
      refresh() { pkill -RTMIN+${toString waybarMicSignal} '^.waybar-wrapped$' || true; }

      # --custom-message is display-only: unlike `--input-volume mute-toggle`
      # it doesn't touch the source, so wpctl and the latch above stay the
      # only things that decide state and the OSD can't disagree with waybar.
      # Both icons are Freedesktop names, present in Adwaita.
      osd() {
        swayosd-client --custom-message "$1" --custom-icon "$2" >/dev/null 2>&1 || true
      }

      # Muting only @DEFAULT_AUDIO_SOURCE@ isn't enough to call the mic shut:
      # the default moves. A bluetooth headset is the default while connected,
      # so a laptop that slept with one paired wakes with the *built-in* mic as
      # default -- and that node was never muted, i.e. actually live. Mute the
      # default first so the mic a hold just closed closes promptly, then sweep
      # the rest.
      # The sweep is best-effort: pipefail would otherwise let a pw-dump that
      # can't reach pipewire abort the caller before it gets to refresh, and
      # the mute that actually matters has already happened by then.
      mute_all() {
        wpctl set-mute "$src" 1
        {
          pw-dump | jq -r '
            .[] | select(.type == "PipeWire:Interface:Node")
                | select(.info.props."media.class" == "Audio/Source") | .id
          ' | while read -r id; do wpctl set-mute "$id" 1 || true; done
        } || true
      }

      # Put the mic back to whatever the latch says the baseline is.
      apply() {
        if [ -e "$latch" ]; then wpctl set-mute "$src" 0; else mute_all; fi
      }

      case "''${1:-status}" in
        # When the mic is live, Alt+Space mutes for good -- it clears the latch
        # rather than inverting it for the hold, so the release below has
        # nothing to undo. When it's muted, the same key is push-to-talk.
        press)
          if [ -e "$latch" ]; then
            rm -f "$latch"
            mute_all
            osd 'Mic muted' microphone-sensitivity-muted-symbolic
          else
            wpctl set-mute "$src" 0
          fi
          refresh
          ;;
        # The latch is normally gone by now (press cleared it), so this mutes;
        # it only leaves the mic open if the gear key re-latched mid-hold.
        release)
          apply
          refresh
          ;;
        # Only the latching toggle shows an OSD: popping one up on every
        # push-to-talk press and release would be constant visual noise, and
        # waybar already covers that case.
        toggle)
          if [ -e "$latch" ]; then
            rm -f "$latch"
            mute_all
            osd 'Mic muted' microphone-sensitivity-muted-symbolic
          else
            : > "$latch"
            wpctl set-mute "$src" 0
            osd 'Mic live' microphone-sensitivity-high-symbolic
          fi
          refresh
          ;;
        # Start every session muted, with no latch held over from the last one.
        init)
          rm -f "$latch"
          apply
          refresh
          ;;
        # Suspend tears down source nodes (and reshuffles which one is default),
        # so the baseline has to be re-asserted on wake rather than assumed to
        # have survived. Driven by swayidle's after-resume hook.
        resume)
          apply
          refresh
          ;;
        # Muted vs open comes from wireplumber; the latch only says whether
        # that is the baseline or an Alt+Space override of it.
        status)
          if wpctl get-volume "$src" | grep -q MUTED; then
            printf '{"text":"󰍭","class":"muted","tooltip":"Microphone muted — hold Alt+Space to talk, gear key to unmute"}\n'
          elif [ -e "$latch" ]; then
            printf '{"text":"󰍬","class":"live","tooltip":"Microphone open — Alt+Space or gear key to mute"}\n'
          else
            printf '{"text":"󰍬","class":"talking","tooltip":"Microphone open while Alt+Space is held"}\n'
          fi
          ;;
        *)
          echo "usage: micctl press|release|toggle|init|resume|status" >&2
          exit 1
          ;;
      esac
    '';
  };

  homeModule =
    { config, ... }:
    {
      # micctl is on PATH so waybar's custom/mic module can call it by name.
      home.packages = [
        pkgs.walker
        pkgs.elephant
        micctl
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

      programs.hyprlock = {
        enable = true;
        settings = {
          # hyprlock 0.9.6's general block only has hide_cursor -- grace and
          # fade-in are CLI flags (-g/--no-fade-in) passed below instead.
          general.hide_cursor = true;

          background = [
            {
              monitor = "";
              path = "screenshot";
              blur_passes = 3;
              blur_size = 7;
              noise = 0.0117;
              contrast = 1.3;
              brightness = 0.8;
              vibrancy = 0.2;
              vibrancy_darkness = 0.0;
            }
          ];

          input-field = [
            {
              monitor = "";
              size = "300, 60";
              outline_thickness = 4;
              dots_size = 0.26;
              dots_spacing = 0.3;
              dots_center = true;
              outer_color = "rgba(${hex theme.neutral}ff)";
              inner_color = "rgba(${hex theme.background'}cc)";
              font_color = "rgba(ffffffff)";
              check_color = "rgba(${hex theme.secondary}ff)";
              fail_color = "rgba(${hex theme.danger}ff)";
              fade_on_empty = true;
              placeholder_text = "<i>Password...</i>";
              hide_input = false;
              position = "0, -120";
              halign = "center";
              valign = "center";
            }
          ];

          label = [
            {
              monitor = "";
              text = ''cmd[update:1000] date +"%H:%M"'';
              color = "rgba(ffffffff)";
              font_size = 90;
              font_family = "JetBrainsMono Nerd Font";
              position = "0, 200";
              halign = "center";
              valign = "center";
            }
            {
              monitor = "";
              text = ''cmd[update:60000] date +"%A, %d %B"'';
              color = "rgba(ffffffff)";
              font_size = 25;
              font_family = "JetBrainsMono Nerd Font";
              position = "0, 120";
              halign = "center";
              valign = "center";
            }
          ];
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
          # --no-fade-in: before-sleep fires right as the system suspends, and
          # hyprlock's default fade-in animation can lose the race against
          # suspend actually happening, leaving widgets (the clock included)
          # stuck mid-render. -g 2: equivalent to the old (invalid) general
          # { grace = 2; }.
          before-sleep = "${config.programs.hyprlock.package}/bin/hyprlock --no-fade-in -g 2";
          lock = "${config.programs.hyprlock.package}/bin/hyprlock --no-fade-in -g 2";
          # Re-mute on wake: see micctl's resume branch. swayidle already has
          # the logind connection this needs, courtesy of before-sleep.
          after-resume = "${micctl}/bin/micctl resume";
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
            { command = "${micctl}/bin/micctl init"; }
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
                }
              ))
              // {
                # Push-to-talk. The flags sit in the key position because
                # home-manager pastes it verbatim after `bindsym`: --no-repeat
                # stops key repeat from re-running unmute for the whole hold.
                # Suppress home-manager's default `${mod}+space focus
                # mode_toggle`, which would otherwise shadow the two bindings
                # below.
                "${mod}+space" = null;
                "--no-repeat ${mod}+space" = exec "${micctl}/bin/micctl press";
                "--release ${mod}+space" = exec "${micctl}/bin/micctl release";
                # The gear key in the function row (Framework 13's F12 media
                # function) is Media Select -- evdev KEY_MEDIA, keysym
                # XF86AudioMedia -- and comes from the internal AT keyboard.
                "${mod}+XF86AudioMedia" = exec "${micctl}/bin/micctl toggle";

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

    # Picks which output to share for ScreenCast via walker's dmenu mode,
    # instead of xdg-desktop-portal-wlr's built-in (layer-shell) chooser.
    # Must go through this option rather than a plain xdg.configFile:
    # xdg-desktop-portal-wlr's systemd unit is started with an explicit
    # --config=<store path>, which always wins over $XDG_CONFIG_HOME.
    xdg.portal.wlr.settings.screencast = {
      chooser_type = "dmenu";
      chooser_cmd = "${pkgs.walker}/bin/walker --dmenu --placeholder 'Share which output?'";
    };

    # programs.sway sets this for swaylock itself (wayland-session.nix), but
    # not for hyprlock, so it has to be declared explicitly here.
    security.pam.services.hyprlock = { };

    home-manager.users.${cfg.user} = homeModule;
  };
}
