{
  # xdg.configFile."mimeapps.list".force = true;
  xdg.mimeApps = {
    enable = true;
    defaultApplications =
      let
        browser = "firefox";
        pdf = "org.gnome.Evince.desktop";
        images = "org.gnome.eog.desktop";
      in
      {
        "application/pdf" = [ pdf ];
        "text/html" = [ browser ];
        "x-scheme-handler/http" = [ browser ];
        "x-scheme-handler/https" = [ browser ];
        "x-scheme-handler/about" = [ browser ];
        "x-scheme-handler/unknown" = [ browser ];
      };
  };
}
