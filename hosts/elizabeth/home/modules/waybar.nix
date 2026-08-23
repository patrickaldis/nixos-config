{ theme, pkgs, ... }:
{
  programs.waybar = {
    enable = true;
    settings.mainBar = {
      modules-left = [
        "hyprland/workspaces"
        "sway/workspaces"
        "sway/scratchpad"
        "mpris"
      ];
      modules-center = [ "clock" ];
      modules-right = [
        "tray"
        "custom/pulls"
        "network"
        "pulseaudio"
        "battery"
        "custom/power"
      ];
      layer = "bottom";
      mpris = {
        format = "{player_icon}  {title} - {artist}";
        format-paused = "󰐊  {title} - {artist}";
        title-len = 30;
        artist-len = 20;
        player-icons = {
          default = "🎵";
          spotify = "";
        };
        ignored-players = [ "chromium" ];
        on-click = "${pkgs.playerctl}/bin/playerctl play-pause";
      };
      network = {
        format-wifi = "{essid} ";
        format-ethernet = "{ifname} ";
        format-disconnected = "";
        max-length = 50;
        on-click = "nm-connection-editor";
      };
      "sway/scratchpad" = {
        format = "{icon} {count}";
        show-empty = false;
        format-icons = [
          ""
          ""
        ];
        tooltip = true;
        tooltip-format = "{app} : {title}";
      };
      tray = {
        icon-size = 15;
        spacing = 10;
        show-passive-items = true;
      };

      clock = {
        tooltip-format = "<big>{:%Y %B}</big>\n<tt><small>{calendar}</small></tt>";
        format = "{:%R  %A %b %d}";
      };

      battery = {
        format = "{capacity} {icon}";
        format-icons = [
          "󱃍"
          "󰁺"
          "󰁻"
          "󰁼"
          "󰁽"
          "󰁾"
          "󰁿"
          "󰂀"
          "󰂁"
          "󰂂"
          "󰁹"
        ];
      };

      pulseaudio = {
        format = "{volume}% {icon}";
        format-muted = "0% {icon} ";
        format-source = "{volume}% ";
        format-source-muted = "";
        format-icons = {
          headphone = "󰋋";
          hands-free = "󰋋";
          headset = "󰋋";
          phone = "";
          portable = "";
          car = "";
          default = [
            ""
            ""
            ""
          ];
        };
        on-click = "sh ~/.config/waybar/swap-sink";
        on-click-middle = "blueberry";
      };
      "custom/power" = {
        exec = "swaync-client -c";
        on-click = "swaync-client -t";
        interval = 1;
      };
    };
    style =
      let
        font-size = "16";
      in
      /* css */ ''
        * {
            border: none;
            font-family: JetBrainsMono NF;
        }
        body {

        }

        window#waybar {
            color: #ffffff;
            background: #282A2E;
        }
        /*-----module groups----*/
        .modules-right {
          background-color: #282A2E;
            font-size: 16px;
        }
        .modules-center {
          background-color: #282A2E;
            font-size: 16px;
        } .modules-left {
          background-color: #282A2E;
            font-size: 16px;
        }
        /*-----modules indv----*/
        #workspaces button {
            color: #ffffff;
            background-color: #282A2E;
            padding: 1px 5px;
            margin: 3px 3px;
        }
        #workspaces button:hover {
            box-shadow: inherit;
          background: #FA768B;
        }

        #workspaces button.active {
          background: #FA768B;
            color: #282A2E;
        }
        #workspaces button.focused {
          background: #FA768B;
            color: #282A2E;
        }
        #scratchpad {
            padding: 0px 10px;
        }
        button {
            color: #ffffff;
            border: none;
        }
        button:hover {
            color: #FA768B;
            background: #303446;
            box-shadow: inherit;
            text-shadow: inherit;
        }
        #clock,
        #battery,
        #cpu,
        #memory,
        #temperature,
        #network,
        #pulseaudio,
        #custom-media,
        #tray,
        #mode,
        #custom-power,
        #custom-menu,
        #custom-waybar-mpris {
            padding: 0 10px;
        }
        #idle_inhibitor {
            padding: 0 10px;
            font-size: 16px;
        }
        #mode {
            color: #FA768B;
            font-weight: bold;
        }
        #custom-power {
            background-color: #FA768B;
            color: #282A2E;
            border-radius: 5px;
            font-size: 16px;
            margin: 3px 3px 3px 3px;
        }
        #custom-power:hover {
            color: #FA768B;
            background: #303446;
        }
        /*-----Indicators----*/
        #idle_inhibitor.activated {
            color: #FA768B;
        }
        #pulseaudio.muted {
            color: #FA768B;
        }
        #battery.charging {
            color: #FA768B;
        }
        #battery.warning:not(.charging) {
          color: #e6e600;
        }
        #battery.critical:not(.charging) {
            color: #cc3436;
        }
        #temperature.critical {
            color: #cc3436;
        }
        #mpris {
          margin-left: 20px;
        }
      '';
  };
}
