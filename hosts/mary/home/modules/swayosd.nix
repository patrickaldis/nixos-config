{ pkgs, ... }:
{
  services.swayosd = {
    enable = true;
    stylePath =
      let
        css = (
          pkgs.writeText "style.css" /* css */ ''
            @define-color background	#1d2021;
            @define-color border		#505050;
            @define-color text			#ebdbb2;
            @define-color muted         #bdae93;
            @define-color accent        #83a598;

            window#osd {
              padding: 0px 6px;
              border: 1px solid @border;
              border-radius: 8px;
              background: @background;
              box-shadow: 1px 2px 2px black;
            }

            image, label {
                color: @text;
                font-size: 16px;
            }

            progressbar:disabled, image:disabled {
                opacity: 0.5;
            }

            progressbar {
                min-height: 6px;
                border-radius: 999px;
                background: transparent;
                border: none;
            }

            trough {
                min-height: inherit;
                border-radius: inherit;
                border: none;
                background: @border;
            }
            progress {
                min-height: inherit;
                border-radius: inherit;
                border: none;
                background: @accent;
            }

            #container {
                margin:6px;
            }
          ''
        );
      in
      "${css}";
  };
}
