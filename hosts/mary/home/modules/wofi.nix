{ theme, ... }:
{
  programs.wofi = {
    enable = true;
    settings = {
      show = "drun";
      insensitive = true;
      key_down = "Ctrl-j";
      key_up = "Ctrl-k";
      no_actions = true;
      width = "18%";
      allow_images = true;
      term = "kitty";
    };
    style = /* css */ ''
      window {
          margin: 0px;
          border: 2px solid #484d6f;
          background-color: #282a36;
          font-family: JetBrainsMono Nerd Font Mono;
          font-size: 17px;
          border-radius: 10px;
      }

      #input {
          margin: 5px;
          border: none;
          color: #f8f8f2;
          background-color: #44475a;
      }
      #input:selected {
          border: none;
      }


      #inner-box {
          margin: 5px;
          border: none;
          background-color: #282A2E;
      }

      #outer-box {
          margin: 5px;
          border: none;
          background-color: #282A2E;
      }

      #scroll {
          margin: 0px;
          border: none;
      }

      #text {
          margin: 5px;
          border: none;
          color: #f8f8f2;
      }

      #entry:selected {
          background-color: #44475a;
          border-radius: 5px;
      }

      #img {
          background-color: #75758A;
          border-radius: 2px;
          padding: 2px;
      }

    '';
  };
}
