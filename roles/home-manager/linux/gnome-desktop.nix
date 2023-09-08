{ config, pkgs, lib, home-manager, fish-configs, ... }:

let
  system = pkgs.system;
  homeDir = config.home.homeDirectory;
in {
  home.packages = [
    fish-configs.packages.${system}.fish
    pkgs.gnome.dconf-editor
    pkgs.gnome.gnome-boxes
    pkgs.gnome.gnome-terminal
    pkgs.gnome.gnome-tweaks
    pkgs.gnomeExtensions.caffeine
    pkgs.gnomeExtensions.gsconnect
    pkgs.gnomeExtensions.just-perfection
    pkgs.gnomeExtensions.paperwm
    #pkgs.gnomeExtensions.pop-shell
    pkgs.gnomeExtensions.tray-icons-reloaded
    #pkgs.pop-launcher
    pkgs.gnomeExtensions.switcher
  ];

  home.file.".config/pop-shell/config.json" = {
    enable = false;
    text = ''
      {
        "float": [
          {
            "class": "1Password"
          },
          {
            "class": "Rustdesk"
          }
        ],
        "skiptaskbarhidden": [],
        "log_on_focus": false
      }
    '';
  };

  home.file.".config/paperwm/user.js" = {
    enable = true;
    text = ''
      // -*- mode: gnome-shell -*-
      var Meta = imports.gi.Meta;
      var Clutter = imports.gi.Clutter;
      var St = imports.gi.St;
      var Main = imports.ui.main;
      var Shell = imports.gi.Shell;

      // Extension local imports
      var Extension, Me, Tiling, Utils, App, Keybindings, Examples;

      function init() {
          // Runs _only_ once on startup

          // Initialize extension imports here to make gnome-shell-reload work
          Extension = imports.misc.extensionUtils.getCurrentExtension();
          Me = Extension.imports.user;
          Tiling = Extension.imports.tiling;
          Utils = Extension.imports.utils;
          Keybindings = Extension.imports.keybindings;
          Examples = Extension.imports.examples;
          App = Extension.imports.app;

          Tiling.defwinprop({
              wm_class: "1Password",
              scratch_layer: true,
          });

          Tiling.defwinprop({
              wm_class: "Code",
              preferredWidth: "100%",
          });

          Tiling.defwinprop({
              wm_class: "firefox",
              preferredWidth: "100%",
          });

          Tiling.defwinprop({
              wm_class: "org.wezfurlong.wezterm",
              preferredWidth: "100%",
          });
      }

      function enable() {
          // Runs on extension reloads, eg. when unlocking the session
      }

      function disable() {
          // Runs on extension reloads eg. when locking the session (`<super>L).
      }
    '';
  };

  # Download wallpaper
  home.file.".wallpaper.png" = {
    source = builtins.fetchurl {
      url = "https://raw.githubusercontent.com/NixOS/nixos-artwork/ac04f06feb980e048b4ab2a7ca32997984b8b5ae/wallpapers/nix-wallpaper-dracula.png";
      sha256 = "sha256:07ly21bhs6cgfl7pv4xlqzdqm44h22frwfhdqyd4gkn2jla1waab";
    };
  };

  dconf.settings = {
    "org/gnome/desktop/input-sources" = {
      xkb-options = ["caps:super"];
    };
    "apps/guake/general" = {
      abbreviate-tab-names = false;
      compat-delete = "delete-sequence";
      default-shell = "${homeDir}/.nix-profile/bin/fish";
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
      quick-open-command-line = "code %(file_path)s";
      restore-tabs-notify = false;
      restore-tabs-startup = false;
      save-tabs-when-changed = false;
      schema-version = "3.9.0";
      scroll-keystroke = true;
      start-at-login = true;
      use-default-font = false;
      use-login-shell = false;
      use-popup = false;
      use-scrollbar = false;
      use-trayicon = false;
      window-halignment = 0;
      window-height = 50;
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
    "apps/guake/style" = {
      cursor-shape = 1;
    };
    "apps/guake/style/background" = {
      transparency = 100;
    };
    "apps/guake/style/font" = {
      allow-bold = true;
      palette = "#3B3B42425252:#BFBF61616A6A:#A3A3BEBE8C8C:#EBEBCBCB8B8B:#8181A1A1C1C1:#B4B48E8EADAD:#8888C0C0D0D0:#E5E5E9E9F0F0:#4C4C56566A6A:#BFBF61616A6A:#A3A3BEBE8C8C:#EBEBCBCB8B8B:#8181A1A1C1C1:#B4B48E8EADAD:#8F8FBCBCBBBB:#ECECEFEFF4F4:#D8D8DEDEE9E9:#2E2E34344040";
      palette-name = "Nord";
      style = "JetBrainsMono Nerd Font 14";
    };
    "org/gnome/shell" = {
      disable-user-extensions = false;
      disabled-extensions = [
        "disabled"
        "ubuntu-dock@ubuntu.com"
        "ding@rastersoft.com"
      ];
      enabled-extensions = [
        "caffeine@patapon.info"
        "gsconnect@andyholmes.github.io"
        "just-perfection-desktop@just-perfection"
        "native-window-placement@gnome-shell-extensions.gcampax.github.com"
        "user-theme@gnome-shell-extensions.gcampax.github.com"
        "paperwm@hedning:matrix.org"
        "switcher@landau.fi"
      ];
      favorite-apps = ["firefox.desktop" "wezterm.desktop"];
      had-bluetooth-devices-setup = true;
      remember-mount-password = false;
      welcome-dialog-last-shown-version = "42.4";
    };
    "org/gnome/shell/keybindings" = {
      switch-to-application-1 = "disabled";
      switch-to-application-2 = "disabled";
      switch-to-application-3 = "disabled";
      switch-to-application-4 = "disabled";
    };
    "org/gnome/mutter" = {
      dynamic-workspaces = false;
      workspaces-only-on-primary = false;
    };
    "org/gnome/shell/extensions/user-theme" = {
      name = "Nordic-darker";
    };
    "org/gnome/shell/extensions/just-perfection" = {
      accessibility-menu = true;
      app-menu = true;
      app-menu-icon = true;
      background-menu = true;
      controls-manager-spacing-size = 22;
      dash = true;
      dash-icon-size = 0;
      double-super-to-appgrid = true;
      gesture = true;
      hot-corner = false;
      osd = false;
      panel = false;
      panel-arrow = true;
      panel-corner-size = 1;
      panel-in-overview = true;
      ripple-box = false;
      search = false;
      show-apps-button = true;
      startup-status = 0;
      theme = true;
      window-demands-attention-focus = true;
      window-picker-icon = false;
      window-preview-caption = true;
      window-preview-close-button = true;
      workspace = true;
      workspace-background-corner-size = 15;
      workspace-popup = false;
      workspaces-in-app-grid = true;
    };
    "org/gnome/shell/extensions/switcher" = {
      show-switcher = ["<Super>space"];
      max-width-percentage = lib.hm.gvariant.mkUint32 40;
      font-size = lib.hm.gvariant.mkUint32 20;
    };
    "org/gnome/shell/extensions/paperwm" = {
      use-default-background = true;
      show-window-position-bar = false;
    };

    "org/gnome/shell/extensions/paperwm/keybindings" = {
      switch-right = ["<Super>bracketright"];
      switch-left = ["<Super>bracketleft"];
      move-left = ["<Shift><Super>braceleft"];
      move-right = ["<Shift><Super>braceright"];
    };

    "org/gnome/desktop/background" = {
      color-shading = "solid";
      picture-options = "zoom";
      picture-uri = "file://${homeDir}/.wallpaper.png";
      picture-uri-dark = "file://${homeDir}/.wallpaper.png";
    };
    "org/gnome/desktop/screensaver" = {
      color-shading = "solid";
      picture-options = "zoom";
      picture-uri = "file://${homeDir}/.wallpaper.png";
      picture-uri-dark = "file://${homeDir}/.wallpaper.png";
    };
    "org/gnome/desktop/interface" = {
      clock-show-seconds = true;
      clock-show-weekday = true;
      color-scheme = "prefer-dark";
      enable-hot-corners = false;
      font-antialiasing = "grayscale";
      font-hinting = "slight";
      gtk-theme = "Nordic";
      toolkit-accessibility = true;
    };
    "org/gnome/desktop/wm/keybindings" = {
      activate-window-menu = ["disabled"];
      toggle-message-tray = ["disabled"];
      close = ["<Super>q"];
      maximize = ["disabled"];
      minimize = ["<Super>comma"];
      move-to-monitor-down = ["disabled"];
      move-to-monitor-left = ["disabled"];
      move-to-monitor-right = ["disabled"];
      move-to-monitor-up = ["disabled"];
      move-to-workspace-1 = ["<Shift><Super>1"];
      move-to-workspace-2 = ["<Shift><Super>2"];
      move-to-workspace-3 = ["<Shift><Super>3"];
      move-to-workspace-4 = ["<Shift><Super>4"];
      move-to-workspace-down = ["disabled"];
      move-to-workspace-up = ["disabled"];
      switch-to-workspace-1 = ["<Super>1"];
      switch-to-workspace-2 = ["<Super>2"];
      switch-to-workspace-3 = ["<Super>3"];
      switch-to-workspace-4 = ["<Super>4"];
      switch-to-workspace-left = ["disabled"];
      switch-to-workspace-right = ["disabled"];
      switch-input-source = ["disabled"];
      switch-input-source-backward = ["disabled"];
      toggle-maximized = ["<Super>Up"];
      unmaximize = ["disabled"];
    };
    "org/gnome/desktop/wm/preferences" = {
      button-layout = "close,minimize,maximize:appmenu";
      num-workspaces = 10;
    };
    "org/gnome/shell/extensions/pop-shell" = {
      focus-right = ["disabled"];
      tile-by-default = true;
      tile-enter = ["disabled"];
      activate-launcher = ["<Super>space"];
    };
    "org/gnome/desktop/notifications" = {
      show-in-lock-screen = false;
    };
    "org/gnome/desktop/peripherals/touchpad" = {
      tap-to-click = true;
      two-finger-scrolling-enabled = true;
    };
    "org/gnome/terminal/legacy" = {
      default-show-menubar = false;
      headerbar = "@mb false";
    };
    "org/gnome/terminal/legacy/profiles:" = {
      default = "3797f158-f495-4609-995f-286da69c8d86";
      list = [
        "3797f158-f495-4609-995f-286da69c8d86"
      ];
    };
    "org/gnome/terminal/legacy/profiles:/:3797f158-f495-4609-995f-286da69c8d86" = {
      background-color = "#2E3440";
      bold-color = "#D8DEE9";
      bold-color-same-as-fg = true;
      cursor-background-color = "rgb(216,222,233)";
      cursor-colors-set = true;
      cursor-foreground-color = "rgb(59,66,82)";
      cursor-shape = "ibeam";
      custom-command = "${homeDir}/.nix-profile/bin/tmux";
      font = "JetBrainsMonoNL Nerd Font 12";
      foreground-color = "#D8DEE9";
      highlight-background-color = "rgb(136,192,208)";
      highlight-colors-set = true;
      highlight-foreground-color = "rgb(46,52,64)";
      nord-gnome-terminal-version="0.1.0";
      use-custom-command = true;
      use-system-font = false;
      use-theme-background = false;
      use-theme-colors = false;
      use-theme-transparency = false;
      use-transparent-background = false;
      visible-name = "Nord";
      scrollbar-policy = "never";
      palette = [
        "#3B4252"
        "#BF616A"
        "#A3BE8C"
        "#EBCB8B"
        "#81A1C1"
        "#B48EAD"
        "#88C0D0"
        "#E5E9F0"
        "#4C566A"
        "#BF616A"
        "#A3BE8C"
        "#EBCB8B"
        "#81A1C1"
        "#B48EAD"
        "#8FBCBB"
        "#ECEFF4"
      ];
    };
    "org/gnome/tweaks" = {
      show-extensions-notice = false;
    };
    "org/gnome/settings-daemon/plugins/media-keys" = {
      next = [ "<Shift><Control>n" ];
      previous = [ "<Shift><Control>p" ];
      play = [ "<Shift><Control>space" ];
      terminal = "disabled";
      logout = [ "<Shift><Super>e" ];
      custom-keybindings = [
        "/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom0/"
        "/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom1/"
        "/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom2/"
        #"/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom3/"
        "/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom4/"
        "/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom5/"
        "/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom6/"
        "/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom7/"
        "/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom8/"
      ];
    };
    "org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom0" = {
      name = "terminal super";
      command = "wezterm";
      binding = "<Super>Return";
    };
    "org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom1" = {
      name = "terminal ctrl_alt";
      command = "wezterm";
      binding = "<Ctrl><Alt>t";
    };
    "org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom2" = {
      name = "rofi-1pass";
      command = "1password --quick-access";
      binding = "<Ctrl><Super>s";
    };
    #"org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom3" = {
    #  name = "launcher";
    #  command = "albert --show";
    #  binding = "<Super>Space";
    #};
    "org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom4" = {
      binding = "<Super><Shift>s";
      command = "bash -c 'gnome-screenshot -a -f /tmp/screenshot.png && xclip -in -selection clipboard -target image/png /tmp/screenshot.png'";
      name = "screenshot";
    };
    "org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom5" = {
      binding = "<Shift><Control>e";
      command = "${homeDir}/bin/vim-ime.py --cmd 'gnome-terminal --geometry=60x8 -- vim' --outfile '${homeDir}/tmp/vim-ime.txt'";
      name = "vim-ime";
    };
    "org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom6" = {
      binding = "<Shift><Control>b";
      command = "bash -c 'notify-send $(acpi -b | grep -Eo [0-9]+%)'";
      name = "battpop";
    };
    "org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom7" = {
      binding = "<Control>grave";
      command = "guake";
      name = "guake";
    };
    "org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom8" = {
      binding = "<Shift><Control>d";
      command = "bash -c 'notify-send \"$(date \"+%T\")\"'";
      name = "datepop";
    };
  };
  # End dconf.settings
}
