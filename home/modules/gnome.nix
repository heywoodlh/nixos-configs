{ config, lib, pkgs, nixpkgs-stable, nixpkgs-lts, home-manager, myFlakes, light-wallpaper, dark-wallpaper, ... }:

with lib;

let
  cfg = config.heywoodlh.home.gnome;
  system = pkgs.stdenv.hostPlatform.system;
  gnome-pkgs = nixpkgs-lts.legacyPackages.${system};
  myGnomeExtensionsInstaller = myFlakes.packages.${system}.gnome-install-extensions;
  pkgs-stable = import nixpkgs-stable {
    inherit system;
    config.allowUnfree = true;
  };
  myTmux = myFlakes.packages.${system}.tmux;
  battpop = pkgs.writeShellScript "battpop" ''
    ${pkgs.libnotify}/bin/notify-send $(${pkgs.acpi}/bin/acpi -b | ${pkgs.gnugrep}/bin/grep -Eo [0-9]+%)
  '';
  datepop = pkgs.writeShellScript "datepop" ''
    ${pkgs.libnotify}/bin/notify-send "$(${pkgs.coreutils}/bin/date "+%T")"
  '';
in {
  options = {
    heywoodlh.home.gnome = mkOption {
      default = false;
      description = ''
        Enable heywoodlh gnome configuration.
      '';
      type = types.bool;
    };
  };

  config = mkIf cfg {
    heywoodlh.home.vicinae.enable = true;

    home.packages = with gnome-pkgs; [
      # Fallback to old name if undefined (i.e. on Ubuntu LTS)
      (if (builtins.hasAttr "dconf-editor" gnome-pkgs) then gnome-pkgs.dconf-editor else gnome.dconf-editor)
      (if (builtins.hasAttr "gnome-boxes" gnome-pkgs) then gnome-pkgs.gnome-boxes else gnome.gnome-boxes)
      (if (builtins.hasAttr "gnome-terminal" gnome-pkgs) then gnome-pkgs.gnome-terminal else gnome.gnome-terminal)
      (if (builtins.hasAttr "gnome-tweaks" gnome-pkgs) then gnome-pkgs.gnome-tweaks else gnome.gnome-tweaks)
      pkgs.epiphany
      gnome-extensions-cli
      pkgs-stable.gnomeExtensions.pop-shell
    ];

    # Enable unclutter
    services.unclutter = {
      enable = true;
      timeout = 3;
      extraOptions = [
        "exclude-root"
        "ignore-scrolling"
      ];
    };

    # Enable guake
    heywoodlh.home.guake = true;

    heywoodlh.home.autostart = [
      {
        name = "Emote";
        command = "${pkgs.emote}/bin/emote";
      }
    ];

    heywoodlh.home.applications = [
      {
        name = "Emote";
        command = "${pkgs.emote}/bin/emote";
      }
    ];

    home.file.".config/pop-shell/config.json" = {
      enable = true;
      text = ''
        {
          "float": [
            {
              "class": "1Password"
            },
            {
              "class": "Rustdesk"
            },
            {
              "class": ".guake-wrapped"
            },
            {
              "class": "emote"
            },
            {
              "title": "Vicinae Launcher"
            }
          ],
          "skiptaskbarhidden": [],
          "log_on_focus": false
        }
      '';
    };

    # Epiphany extensions
    home.file."share/epiphany/dark-reader.xpi" = {
      source = builtins.fetchurl {
        url = "https://addons.mozilla.org/firefox/downloads/file/4205543/darkreader-4.9.73.xpi";
        sha256 = "sha256:06lgnfi0azk62b7yzw8znyq955v2iypsy35d1nw6p2314prryfbw";
      };
    };
    home.file."share/epiphany/vim-vixen.xpi" = {
      source = builtins.fetchurl {
        url = "https://addons.mozilla.org/firefox/downloads/file/3845233/vim_vixen-1.2.3.xpi";
        sha256 = "sha256:1dg9m6iwap1xbvw6pa6mhrvaqccjrrb0ns9j38zzspg6r1xcg1lg";
      };
    };
    home.file."share/epiphany/redirector.xpi" = {
      source = builtins.fetchurl {
        url = "https://addons.mozilla.org/firefox/downloads/file/3535009/redirector-3.5.3.xpi";
        sha256 = "sha256:0w8g3kkr0hdnm8hxnhkgxpf0430frzlxkdpcsq5qsx2fjkax7nzd";
      };
    };

    # Epiphany CSS
    home.file.".local/share/epiphany/user-stylesheet.css" = {
      text = ''
        #overview {
          background-color: #3B4252 !important;
          max-width: 100% !important;
          max-height: 100% !important;
          position: fixed !important;
        }

        #overview .overview-title {
          color: white !important;
        }
      '';
    };

    home.file."Pictures/screenshots/.placeholder.txt" = {
      text = "";
    };

    home.activation = {
      # Install extensions with gnome-extensions-cli so I have more control
      install-gnome-extensions = ''
        ${myGnomeExtensionsInstaller}/bin/gnome-ext-install
      '';
      # Kill vicinae if it's running to ensure new version is used
      kill-vicinae = ''
        ${pkgs.procps}/bin/pkill -9 vicinae &>/dev/null || true
      '';
    };

    dconf.settings = {

      "org/gnome/desktop/background" = {
        color-shading = "solid";
        picture-options = "zoom";
        picture-uri = "${dark-wallpaper}";
        picture-uri-dark = "${dark-wallpaper}";
      };

      "org/gnome/desktop/input-sources" = {
        xkb-options = [ "caps:ctrl_shifted_capslock" "altwin:ctrl_win" ];
      };

      "org/gnome/desktop/interface" = {
        clock-show-seconds = true;
        clock-show-weekday = true;
        color-scheme = "prefer-dark";
        enable-hot-corners = false;
        font-antialiasing = "grayscale";
        font-hinting = "slight";
        gtk-theme = "Nordic";
        icon-theme = "Nordic-darker";
        toolkit-accessibility = true;
      };

      "org/gnome/desktop/notifications" = {
        show-in-lock-screen = false;
      };

      "org/gnome/desktop/peripherals/touchpad" = {
        tap-to-click = true;
        two-finger-scrolling-enabled = true;
      };

      "org/gnome/desktop/screensaver" = {
        color-shading = "solid";
        picture-options = "zoom";
        picture-uri = "${dark-wallpaper}";
        picture-uri-dark = "${dark-wallpaper}";
      };

      "org/gnome/desktop/wm/keybindings" = {
        activate-window-menu = [ "disabled" ];
        close = [ "<Super>q" ];
        maximize = [ "disabled" ];
        minimize = [ "<Super>comma" ];
        move-to-monitor-down = [ "disabled" ];
        move-to-monitor-left = [ "disabled" ];
        move-to-monitor-right = [ "disabled" ];
        move-to-monitor-up = [ "disabled" ];
        move-to-workspace-1 = [ "<Shift><Super>1" ];
        move-to-workspace-2 = [ "<Shift><Super>2" ];
        move-to-workspace-3 = [ "<Shift><Super>3" ];
        move-to-workspace-4 = [ "<Shift><Super>4" ];
        move-to-workspace-down = [ "disabled" ];
        move-to-workspace-up = [ "disabled" ];
        switch-input-source = [ "disabled" ];
        switch-input-source-backward = [ "disabled" ];
        switch-to-workspace-1 = [ "<Super>1" ];
        switch-to-workspace-2 = [ "<Super>2" ];
        switch-to-workspace-3 = [ "<Super>3" ];
        switch-to-workspace-4 = [ "<Super>4" ];
        switch-to-workspace-left = [ "<Control>bracketleft" ];
        switch-to-workspace-right = [ "<Control>bracketright" ];
        switch-windows = [ "<Control>Tab" ];
        switch-windows-backward = [ "<Shift><Control>Tab" ];
        toggle-maximized = [ "<Super>Up" ];
        toggle-message-tray = [ "disabled" ];
        unmaximize = [ "disabled" ];
      };

      "org/gnome/desktop/wm/preferences" = {
        button-layout = "close,minimize,maximize:appmenu";
        num-workspaces = 10;
      };

      "org/gnome/desktop/sound" = {
        event-sounds = false;
      };

      "org/gnome/epiphany/web" = {
        enable-user-css = true;
        enable-webextensions = true;
        homepage-url = "about:newtab";
        remember-passwords = false;
      };

      "org/gnome/mutter" = {
        dynamic-workspaces = false;
        workspaces-only-on-primary = false;
      };

      "org/gnome/settings-daemon/plugins/media-keys" = {
        custom-keybindings = [ "/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom0/" "/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom1/" "/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom2/" "/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom4/" "/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom5/" "/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom6/" "/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom7/" "/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom8/" "/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom9/" "/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom10/" ];
        logout = [ "<Shift><Super>e" ];
        play = [ "<Shift><Control>space" ];
        terminal = "disabled";
      };

      "org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom0" = {
        binding = "<Super>Return";
        command = "gnome-terminal";
        name = "terminal super";
      };

      "org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom1" = {
        binding = "<Ctrl><Alt>t";
        command = "gnome-terminal";
        name = "terminal ctrl_alt";
      };

      "org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom2" = {
        binding = "<ctrl><Super>s";
        command = "${pkgs._1password-gui}/bin/1password --quick-access";
        name = "1pass-quick-access";
      };

      "org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom4" = {
        binding = "<Super><Shift>s";
        command = "${pkgs.gnome-screenshot}/bin/gnome-screenshot -ac";
        name = "screenshot";
      };

      "org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom5" = {
        binding = "<Shift><Control>b";
        command = "${battpop}";
        name = "battpop";
      };

      "org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom6" = {
        binding = "<Control>grave";
        command = "${pkgs.guake}/bin/guake";
        name = "guake";
      };

      "org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom7" = {
        binding = "<Shift><Control>d";
        command = "${datepop}";
        name = "datepop";
      };

      "org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom8" = {
        binding = "<Super>space";
        command = "${pkgs.vicinae}/bin/vicinae open";
        name = "launcher";
      };

      "org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom9" = {
        binding = "<Control>space";
        command = "${pkgs.vicinae}/bin/vicinae open";
        name = "launcher";
      };

      "org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom10" = {
        binding = "<Control>s";
        command = "${pkgs._1password-gui}/bin/1password --quick-access";
        name = "1pass-quick-access";
      };

      "org/gnome/shell" = {
        disable-user-extensions = false;
        disabled-extensions = [ "disabled" "ubuntu-dock@ubuntu.com" ];
        enabled-extensions = [
          "caffeine@patapon.info"
          "gsconnect@andyholmes.github.io"
          "just-perfection-desktop@just-perfection"
          "native-window-placement@gnome-shell-extensions.gcampax.github.com"
          "user-theme@gnome-shell-extensions.gcampax.github.com"
          "gnomebedtime@ionutbortis.gmail.com"
          "hide-cursor@elcste.com"
          "space-bar@luchrioh"
          "pip-on-top@rafostar.github.com"
          "pop-shell@system76.com"
        ];
        favorite-apps = [ "firefox.desktop" ];
        had-bluetooth-devices-setup = true;
        remember-mount-password = false;
        welcome-dialog-last-shown-version = "42.4";
      };

      "org/gnome/shell/extensions/bedtime-mode" = {
        bedtime-mode-active = false;
        color-tone-factor = 80;
      };

      "org/gnome/shell/extensions/just-perfection" = {
        accessibility-menu = true;
        app-menu = true;
        app-menu-icon = true;
        background-menu = true;
        clock-menu = false;
        controls-manager-spacing-size = 22;
        dash = true;
        dash-icon-size = 0;
        double-super-to-appgrid = true;
        gesture = true;
        hot-corner = false;
        notification-banner-position = 2;
        osd = false;
        panel = true;
        panel-arrow = true;
        panel-corner-size = 1;
        panel-in-overview = true;
        panel-notification-icon = true;
        panel-size = 36;
        power-icon = true;
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

      "org/gnome/shell/extensions/space-bar/behavior" = {
        indicator-style = "current-workspace";
        smart-workspace-names = false;
      };

      "org/gnome/shell/extensions/user-theme" = {
        name = "Nordic-darker";
      };

      "org/gnome/shell/keybindings" = {
        switch-to-application-1 = "disabled";
        switch-to-application-2 = "disabled";
        switch-to-application-3 = "disabled";
        switch-to-application-4 = "disabled";
        toggle-overview = [ "<Control>k" ];
      };

      "org/gnome/terminal/legacy" = {
        default-show-menubar = false;
        headerbar = false;
      };

      "org/gnome/terminal/legacy/profiles:" = {
        default = "3797f158-f495-4609-995f-286da69c8d86";
        list = [ "3797f158-f495-4609-995f-286da69c8d86" "3797f158-f495-4609-995f-286da69c8d87" ];
      };

      "org/gnome/terminal/legacy/profiles:/:3797f158-f495-4609-995f-286da69c8d86" = {
        background-color = "#2E3440";
        bold-color = "#D8DEE9";
        bold-color-same-as-fg = true;
        cursor-background-color = "rgb(216,222,233)";
        cursor-colors-set = true;
        cursor-foreground-color = "rgb(59,66,82)";
        cursor-shape = "ibeam";
        custom-command = "${myTmux}/bin/tmux";
        font = "JetBrains Mono NL 14";
        foreground-color = "#D8DEE9";
        highlight-background-color = "rgb(136,192,208)";
        highlight-colors-set = true;
        highlight-foreground-color = "rgb(46,52,64)";
        nord-gnome-terminal-version = "0.1.0";
        palette = [ "#3B4252" "#BF616A" "#A3BE8C" "#EBCB8B" "#81A1C1" "#B48EAD" "#88C0D0" "#E5E9F0" "#4C566A" "#BF616A" "#A3BE8C" "#EBCB8B" "#81A1C1" "#B48EAD" "#8FBCBB" "#ECEFF4" ];
        scrollbar-policy = "never";
        use-custom-command = true;
        use-system-font = false;
        use-theme-background = false;
        use-theme-colors = false;
        use-theme-transparency = false;
        use-transparent-background = false;
        visible-name = "Nord";
      };

      "org/gnome/terminal/legacy/profiles:/:3797f158-f495-4609-995f-286da69c8d87" = {
        background-color = "#2E3440";
        bold-color = "#D8DEE9";
        bold-color-same-as-fg = true;
        cursor-background-color = "rgb(216,222,233)";
        cursor-colors-set = true;
        cursor-foreground-color = "rgb(59,66,82)";
        cursor-shape = "ibeam";
        custom-command = "bash";
        font = "JetBrains Mono NL 14";
        foreground-color = "#D8DEE9";
        highlight-background-color = "rgb(136,192,208)";
        highlight-colors-set = true;
        highlight-foreground-color = "rgb(46,52,64)";
        nord-gnome-terminal-version = "0.1.0";
        palette = [ "#3B4252" "#BF616A" "#A3BE8C" "#EBCB8B" "#81A1C1" "#B48EAD" "#88C0D0" "#E5E9F0" "#4C566A" "#BF616A" "#A3BE8C" "#EBCB8B" "#81A1C1" "#B48EAD" "#8FBCBB" "#ECEFF4" ];
        scrollbar-policy = "never";
        use-custom-command = true;
        use-system-font = false;
        use-theme-background = false;
        use-theme-colors = false;
        use-theme-transparency = false;
        use-transparent-background = false;
        visible-name = "Vanilla";
      };

      "org/gnome/tweaks" = {
        show-extensions-notice = false;
      };
    };
  };
}
