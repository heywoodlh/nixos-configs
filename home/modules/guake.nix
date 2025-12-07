{ config, lib, pkgs, myFlakes, ... }:

with lib;

let
  cfg = config.heywoodlh.home.guake;
  system = pkgs.stdenv.hostPlatform.system;
  myTmux = myFlakes.packages.${system}.tmux;
in {
  options = {
    heywoodlh.home.guake = mkOption {
      default = false;
      description = ''
        Enable heywoodlh guake configuration.
      '';
      type = types.bool;
    };
  };

  config = mkIf cfg {
    dconf.settings = {
      "apps/guake/general" = {
        abbreviate-tab-names = false;
        compat-delete = "delete-sequence";
        default-shell = "${myTmux}/bin/tmux";
        display-n = 0;
        display-tab-names = 0;
        gtk-prefer-dark-theme = true;
        gtk-theme-name = "Adwaita-dark";
        gtk-use-system-default-theme = true;
        hide-tabs-if-one-tab = false;
        history-size = 1000;
        load-guake-yml = true;
        max-tab-name-length = 100;
        mouse-display = true;
        open-tab-cwd = true;
        prompt-on-quit = true;
        quick-open-command-line = "${pkgs.xdg-utils}/bin/xdg-open %(file_path)s";
        restore-tabs-notify = false;
        restore-tabs-startup = false;
        save-tabs-when-changed = false;
        schema-version = "3.10";
        scroll-keystroke = true;
        start-at-login = true;
        use-default-font = false;
        use-login-shell = false;
        use-popup = false;
        use-scrollbar = false;
        use-trayicon = false;
        window-halignment = 0;
        window-height = 95;
        window-losefocus = false;
        window-refocus = false;
        window-tabbar = false;
        window-width = 100;
      };

      "org/guake/general" = {
        abbreviate-tab-names = false;
        compat-delete = "delete-sequence";
        default-shell = "${myTmux}/bin/tmux";
        display-n = 0;
        display-tab-names = 0;
        gtk-prefer-dark-theme = true;
        gtk-theme-name = "Adwaita-dark";
        gtk-use-system-default-theme = true;
        hide-tabs-if-one-tab = false;
        history-size = 1000;
        load-guake-yml = true;
        max-tab-name-length = 100;
        mouse-display = true;
        open-tab-cwd = true;
        prompt-on-quit = true;
        quick-open-command-line = "${pkgs.xdg-utils}/bin/xdg-open %(file_path)s";
        restore-tabs-notify = false;
        restore-tabs-startup = false;
        save-tabs-when-changed = false;
        schema-version = "3.10";
        scroll-keystroke = true;
        start-at-login = true;
        use-default-font = false;
        use-login-shell = false;
        use-popup = false;
        use-scrollbar = false;
        use-trayicon = false;
        window-halignment = 0;
        window-height = 95;
        window-losefocus = false;
        window-refocus = false;
        window-tabbar = false;
        window-width = 100;
      };

      "apps/guake/keybindings/local" = {
        focus-terminal-left = "<Primary>braceleft";
        focus-terminal-right = "<Primary>braceright";
        split-tab-horizontal = "<Primary>underscore";
        split-tab-vertical = "<Primary>bar";
      };

      "org/guake/keybindings/local" = {
        focus-terminal-left = "<Primary>braceleft";
        focus-terminal-right = "<Primary>braceright";
        split-tab-horizontal = "<Primary>underscore";
        split-tab-vertical = "<Primary>bar";
      };

      "apps/guake/style" = {
        cursor-shape = 0;
      };

      "org/guake/style" = {
        cursor-shape = 0;
      };

      "apps/guake/style/background" = {
        transparency = 100;
      };

      "org/guake/style/background" = {
        transparency = 100;
      };

      "apps/guake/style/font" = {
        allow-bold = true;
        palette = "#3B3B42425252:#BFBF61616A6A:#A3A3BEBE8C8C:#EBEBCBCB8B8B:#8181A1A1C1C1:#B4B48E8EADAD:#8888C0C0D0D0:#E5E5E9E9F0F0:#4C4C56566A6A:#BFBF61616A6A:#A3A3BEBE8C8C:#EBEBCBCB8B8B:#8181A1A1C1C1:#B4B48E8EADAD:#8F8FBCBCBBBB:#ECECEFEFF4F4:#D8D8DEDEE9E9:#2E2E34344040";
        palette-name = "Nord";
        style = "JetBrains Mono 14";
      };

      "org/guake/style/font" = {
        allow-bold = true;
        palette = "#3B3B42425252:#BFBF61616A6A:#A3A3BEBE8C8C:#EBEBCBCB8B8B:#8181A1A1C1C1:#B4B48E8EADAD:#8888C0C0D0D0:#E5E5E9E9F0F0:#4C4C56566A6A:#BFBF61616A6A:#A3A3BEBE8C8C:#EBEBCBCB8B8B:#8181A1A1C1C1:#B4B48E8EADAD:#8F8FBCBCBBBB:#ECECEFEFF4F4:#D8D8DEDEE9E9:#2E2E34344040";
        palette-name = "Nord";
        style = "JetBrains Mono 14";
      };
    };
  };
}
