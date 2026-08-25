{
  services.swaync = {
    enable = true;
    settings = {
      notification-visibility = {
        transient-apps = {
          state = "transient";
          # To find the app-name, run:
          # dbus-monitor "interface='org.freedesktop.Notifications',member='Notify'"
          app-name = builtins.concatStringsSep "|" [
            "NetworkManager Applet"
            "udiskie"
            "xfce4-power-manager"
            "blueman"
          ];
        };
      };
      notification-action-filter = {
        nm-applet = {
          app-name = "NetworkManager Applet";
          id-matcher = "app.enable-pref::disable-connected-notifications";
        };
      };
    };
  };
}
