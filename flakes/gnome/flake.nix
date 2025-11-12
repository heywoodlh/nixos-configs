{
  description = "GNOME desktop flake";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    nixpkgs-stable.url = "github:NixOS/nixpkgs/nixos-24.05"; # pinned for gnome-extensions-cli instability
    flake-utils.url = "github:numtide/flake-utils";
    fish-flake = {
      url = ../fish;
      inputs.nixpkgs.follows = "nixpkgs";
    };
    vim-flake = {
      url = ../vim;
      inputs.nixpkgs.follows = "nixpkgs";
    };
    vim-ime = {
      flake = false;
      url = "github:heywoodlh/vim-input-editor";
    };
    nordic = {
      flake = false;
      url = "https://github.com/EliverLara/Nordic/releases/download/v2.2.0/Nordic.tar.xz";
    };
    vicinae-nix = {
      url = "github:vicinaehq/vicinae";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };
  outputs = inputs @ {
    self,
    nixpkgs,
    nixpkgs-stable,
    flake-utils,
    fish-flake,
    vim-flake,
    vim-ime,
    nordic,
    vicinae-nix,
  }:
    flake-utils.lib.eachDefaultSystem (system: let
      pkgs = import nixpkgs {
        inherit system;
        config.allowUnfree = true;
      };
      stable-pkgs = nixpkgs-stable.legacyPackages.${system};
      myShell = "${fish-flake.packages.${system}.tmux}/bin/tmux";
      myVim = vim-flake.packages.${system}.vim;
      vimIme = "${vim-ime}/vim-ime.py";
      wallpaper = ./wallpapers/nix-nord.png;
      jetbrains-font = builtins.fetchurl {
        url = "https://download.jetbrains.com/fonts/JetBrainsMono-2.304.zip";
        sha256 = "sha256:1gvv5w0vfzndzp8k7g15j5i3yvnpr5z3imrwjs5flq19xp37cqvg";
      };

      battpop = pkgs.writeShellScript "battpop" ''
        ${pkgs.libnotify}/bin/notify-send $(${pkgs.acpi}/bin/acpi -b | ${pkgs.gnugrep}/bin/grep -Eo [0-9]+%)
      '';
      datepop = pkgs.writeShellScript "datepop" ''
        ${pkgs.libnotify}/bin/notify-send "$(${pkgs.coreutils}/bin/date "+%T")"
      '';
      guakeConf = {
        general = ''
          abbreviate-tab-names=false
          compat-delete='delete-sequence'
          default-shell='${myShell}'
          display-n=0
          display-tab-names=0
          gtk-prefer-dark-theme=true
          gtk-theme-name='Adwaita-dark'
          gtk-use-system-default-theme=true
          hide-tabs-if-one-tab=false
          history-size=1000
          load-guake-yml=true
          max-tab-name-length=100
          mouse-display=true
          open-tab-cwd=true
          prompt-on-quit=true
          quick-open-command-line='${pkgs.xdg-utils}/bin/xdg-open %(file_path)s'
          restore-tabs-notify=false
          restore-tabs-startup=false
          save-tabs-when-changed=false
          schema-version='3.10'
          scroll-keystroke=true
          start-at-login=true
          use-default-font=false
          use-login-shell=false
          use-popup=false
          use-scrollbar=false
          use-trayicon=false
          window-halignment=0
          window-height=95
          window-losefocus=false
          window-refocus=false
          window-tabbar=false
          window-width=100
        '';
        keybindings.local = ''
          focus-terminal-left='<Primary>braceleft'
          focus-terminal-right='<Primary>braceright'
          split-tab-horizontal='<Primary>underscore'
          split-tab-vertical='<Primary>bar'
        '';
        style = {
          base = ''
            cursor-shape=0
          '';
          background = ''
            transparency=100
          '';
          font = ''
            allow-bold=true
            palette='#3B3B42425252:#BFBF61616A6A:#A3A3BEBE8C8C:#EBEBCBCB8B8B:#8181A1A1C1C1:#B4B48E8EADAD:#8888C0C0D0D0:#E5E5E9E9F0F0:#4C4C56566A6A:#BFBF61616A6A:#A3A3BEBE8C8C:#EBEBCBCB8B8B:#8181A1A1C1C1:#B4B48E8EADAD:#8F8FBCBCBBBB:#ECECEFEFF4F4:#D8D8DEDEE9E9:#2E2E34344040'
            palette-name='Nord'
            style='JetBrains Mono 14'
          '';
        };
      };
      vicinaePkg = vicinae-nix.packages.${system}.default;
      vicinae-sh = pkgs.writeShellScriptBin "vicinae" ''
        if ! ${pkgs.ps}/bin/ps aux | ${pkgs.gnugrep}/bin/grep -q "[v]icinae server"
        then
          id=$(notify-send "Starting Vicinae server..." -p)
          ${pkgs.coreutils}/bin/nohup ${vicinaePkg}/bin/vicinae server &
          sleep 2
          if ${pkgs.ps}/bin/ps aux | ${pkgs.gnugrep}/bin/grep -q "[v]icinae server"
          then
            ${pkgs.libnotify}/bin/notify-send --replace-id="$id" "Vicinae server started!"
          else
            ${pkgs.libnotify}/bin/notify-send --replace-id="$id" "Failed to start Vicinae server!"
          fi
        fi
        disown &>/dev/null
        ${vicinaePkg}/bin/vicinae $@
      '';
      dconf-ini = pkgs.writeText "dconf.ini" ''
        [apps/guake/general]
        ${guakeConf.general}
        [org/guake/general]
        ${guakeConf.general}

        [apps/guake/keybindings/local]
        ${guakeConf.keybindings.local}
        [org/guake/keybindings/local]
        ${guakeConf.keybindings.local}

        [apps/guake/style]
        ${guakeConf.style.base}
        [org/guake/style]
        ${guakeConf.style.base}

        [apps/guake/style/background]
        ${guakeConf.style.background}
        [org/guake/style/background]
        ${guakeConf.style.background}

        [apps/guake/style/font]
        ${guakeConf.style.font}
        [org/guake/style/font]
        ${guakeConf.style.font}

        [org/gnome/desktop/background]
        color-shading='solid'
        picture-options='zoom'
        picture-uri='${wallpaper}'
        picture-uri-dark='${wallpaper}'

        [org/gnome/desktop/input-sources]
        xkb-options=@as ['caps:ctrl_shifted_capslock', 'altwin:ctrl_win']

        [org/gnome/desktop/interface]
        clock-show-seconds=true
        clock-show-weekday=true
        color-scheme='prefer-dark'
        enable-hot-corners=false
        font-antialiasing='grayscale'
        font-hinting='slight'
        gtk-theme='Nordic'
        icon-theme='Nordic-darker'
        toolkit-accessibility=true

        [org/gnome/desktop/notifications]
        show-in-lock-screen=false

        [org/gnome/desktop/peripherals/touchpad]
        tap-to-click=true
        two-finger-scrolling-enabled=true

        [org/gnome/desktop/screensaver]
        color-shading='solid'
        picture-options='zoom'
        picture-uri='file://${wallpaper}'
        picture-uri-dark='file://${wallpaper}'

        [org/gnome/desktop/wm/keybindings]
        activate-window-menu=@as ['disabled']
        close=@as ['<Super>q']
        maximize=@as ['disabled']
        minimize=@as ['<Super>comma']
        move-to-monitor-down=@as ['disabled']
        move-to-monitor-left=@as ['disabled']
        move-to-monitor-right=@as ['disabled']
        move-to-monitor-up=@as ['disabled']
        move-to-workspace-1=@as ['<Shift><Super>1']
        move-to-workspace-2=@as ['<Shift><Super>2']
        move-to-workspace-3=@as ['<Shift><Super>3']
        move-to-workspace-4=@as ['<Shift><Super>4']
        move-to-workspace-down=@as ['disabled']
        move-to-workspace-up=@as ['disabled']
        switch-input-source=@as ['disabled']
        switch-input-source-backward=@as ['disabled']
        switch-to-workspace-1=@as ['<Super>1']
        switch-to-workspace-2=@as ['<Super>2']
        switch-to-workspace-3=@as ['<Super>3']
        switch-to-workspace-4=@as ['<Super>4']
        switch-to-workspace-left=@as ['<Control>bracketleft']
        switch-to-workspace-right=@as ['<Control>bracketright']
        switch-windows=['<Control>Tab']
        switch-windows-backward=['<Shift><Control>Tab']
        toggle-maximized=@as ['<Super>Up']
        toggle-message-tray=@as ['disabled']
        unmaximize=@as ['disabled']

        [org/gnome/desktop/wm/preferences]
        button-layout='close,minimize,maximize:appmenu'
        num-workspaces=10

        [org/gnome/desktop/sound]
        event-sounds=false

        [org/gnome/epiphany/web]
        enable-user-css=true
        enable-webextensions=true
        homepage-url='about:newtab'
        remember-passwords=false

        [org/gnome/mutter]
        dynamic-workspaces=false
        workspaces-only-on-primary=false

        [org/gnome/settings-daemon/plugins/media-keys]
        custom-keybindings=@as ['/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom0/','/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom1/','/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom2/','/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom4/','/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom5/','/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom6/','/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom7/','/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom8/','/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom9/','/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom10/','/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom11/']
        logout=@as ['<Shift><Super>e']
        play=@as ['<Shift><Control>space']
        terminal='disabled'

        [org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom0]
        binding='<Super>Return'
        command='gnome-terminal'
        name='terminal super'

        [org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom1]
        binding='<Ctrl><Alt>t'
        command='gnome-terminal'
        name='terminal ctrl_alt'

        [org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom2]
        binding='<Ctrl><Super>s'
        command='${pkgs._1password-gui}/bin/1password --quick-access'
        name='1pass-quick-access'

        [org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom4]
        binding='<Super><Shift>s'
        command='${pkgs.gnome-screenshot}/bin/gnome-screenshot -ac'
        name='screenshot'

        [org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom5]
        binding='<Shift><Control>e'
        command='${vimIme} --cmd "gnome-terminal --geometry=60x8 -- ${myVim}/bin/vim" --outfile "/home/heywoodlh/tmp/vim-ime.txt"'
        name='vim-ime'

        [org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom6]
        binding='<Shift><Control>b'
        command='${battpop}'
        name='battpop'

        [org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom7]
        binding='<Control>grave'
        command='${stable-pkgs.guake}/bin/guake'
        name='guake'

        [org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom8]
        binding='<Shift><Control>d'
        command='${datepop}'
        name='datepop'

        [org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom9]
        binding='<Super>space'
        command='${vicinae-sh}/bin/vicinae'
        name='launcher'

        [org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom10]
        binding='<Control>space'
        command='${vicinae-sh}/bin/vicinae'
        name='launcher'

        [org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom11]
        binding='<Control>s'
        command='${pkgs._1password-gui}/bin/1password --quick-access'
        name='1pass-quick-access'

        [org/gnome/shell]
        disable-user-extensions=false
        disabled-extensions=@as ['disabled','ubuntu-dock@ubuntu.com']
        enabled-extensions=@as ['caffeine@patapon.info','gsconnect@andyholmes.github.io','just-perfection-desktop@just-perfection','native-window-placement@gnome-shell-extensions.gcampax.github.com','user-theme@gnome-shell-extensions.gcampax.github.com','gnomebedtime@ionutbortis.gmail.com','hide-cursor@elcste.com','space-bar@luchrioh','pip-on-top@rafostar.github.com']
        favorite-apps=@as ['firefox.desktop']
        had-bluetooth-devices-setup=true
        remember-mount-password=false
        welcome-dialog-last-shown-version='42.4'

        [org/gnome/shell/extensions/bedtime-mode]
        bedtime-mode-active=false
        color-tone-factor=80

        [org/gnome/shell/extensions/just-perfection]
        accessibility-menu=true
        app-menu=true
        app-menu-icon=true
        background-menu=true
        clock-menu=false
        controls-manager-spacing-size=22
        dash=true
        dash-icon-size=0
        double-super-to-appgrid=true
        gesture=true
        hot-corner=false
        notification-banner-position=2
        osd=false
        panel=true
        panel-arrow=true
        panel-corner-size=1
        panel-in-overview=true
        panel-notification-icon=true
        panel-size=36
        power-icon=true
        ripple-box=false
        search=false
        show-apps-button=true
        startup-status=0
        theme=true
        window-demands-attention-focus=true
        window-picker-icon=false
        window-preview-caption=true
        window-preview-close-button=true
        workspace=true
        workspace-background-corner-size=15
        workspace-popup=false
        workspaces-in-app-grid=true

        [org/gnome/shell/extensions/space-bar/behavior]
        indicator-style='current-workspace'
        smart-workspace-names=false

        [org/gnome/shell/extensions/user-theme]
        name='Nordic-darker'

        [org/gnome/shell/keybindings]
        switch-to-application-1='disabled'
        switch-to-application-2='disabled'
        switch-to-application-3='disabled'
        switch-to-application-4='disabled'
        toggle-overview=['<Control>k']

        [org/gnome/terminal/legacy]
        default-show-menubar=false
        headerbar=false

        [org/gnome/terminal/legacy/profiles:]
        default='3797f158-f495-4609-995f-286da69c8d86'
        list=@as ['3797f158-f495-4609-995f-286da69c8d86','3797f158-f495-4609-995f-286da69c8d87']

        [org/gnome/terminal/legacy/profiles:/:3797f158-f495-4609-995f-286da69c8d86]
        background-color='#2E3440'
        bold-color='#D8DEE9'
        bold-color-same-as-fg=true
        cursor-background-color='rgb(216,222,233)'
        cursor-colors-set=true
        cursor-foreground-color='rgb(59,66,82)'
        cursor-shape='ibeam'
        custom-command='${myShell}'
        font='JetBrains Mono NL 14'
        foreground-color='#D8DEE9'
        highlight-background-color='rgb(136,192,208)'
        highlight-colors-set=true
        highlight-foreground-color='rgb(46,52,64)'
        nord-gnome-terminal-version='0.1.0'
        palette=@as ['#3B4252','#BF616A','#A3BE8C','#EBCB8B','#81A1C1','#B48EAD','#88C0D0','#E5E9F0','#4C566A','#BF616A','#A3BE8C','#EBCB8B','#81A1C1','#B48EAD','#8FBCBB','#ECEFF4']
        scrollbar-policy='never'
        use-custom-command=true
        use-system-font=false
        use-theme-background=false
        use-theme-colors=false
        use-theme-transparency=false
        use-transparent-background=false
        visible-name='Nord'

        [org/gnome/terminal/legacy/profiles:/:3797f158-f495-4609-995f-286da69c8d87]
        background-color='#2E3440'
        bold-color='#D8DEE9'
        bold-color-same-as-fg=true
        cursor-background-color='rgb(216,222,233)'
        cursor-colors-set=true
        cursor-foreground-color='rgb(59,66,82)'
        cursor-shape='ibeam'
        custom-command='bash'
        font='JetBrains Mono NL 14'
        foreground-color='#D8DEE9'
        highlight-background-color='rgb(136,192,208)'
        highlight-colors-set=true
        highlight-foreground-color='rgb(46,52,64)'
        nord-gnome-terminal-version='0.1.0'
        palette=@as ['#3B4252','#BF616A','#A3BE8C','#EBCB8B','#81A1C1','#B48EAD','#88C0D0','#E5E9F0','#4C566A','#BF616A','#A3BE8C','#EBCB8B','#81A1C1','#B48EAD','#8FBCBB','#ECEFF4']
        scrollbar-policy='never'
        use-custom-command=true
        use-system-font=false
        use-theme-background=false
        use-theme-colors=false
        use-theme-transparency=false
        use-transparent-background=false
        visible-name='Vanilla'

        [org/gnome/tweaks]
        show-extensions-notice=false
      '';
      gnome-extensions-script = pkgs.writeShellScriptBin "gnome-ext-install" ''
        declare -a extensions=("caffeine@patapon.info"
                               "gnomebedtime@ionutbortis.gmail.com"
                               "gsconnect@andyholmes.github.io"
                               "just-perfection-desktop@just-perfection"
                               "native-window-placement@gnome-shell-extensions.gcampax.github.com"
                               "hide-cursor@elcste.com"
                               "user-theme@gnome-shell-extensions.gcampax.github.com"
                               "space-bar@luchrioh"
                               "pip-on-top@rafostar.github.com")

        for extension in "''${extensions[@]}"
        do
          ${stable-pkgs.gnome-extensions-cli}/bin/gext install "$extension"
          ${stable-pkgs.gnome-extensions-cli}/bin/gext enable "$extension"
        done
      '';
      renderNix = pkgs.writeShellScript "render-nix" ''
        # wrapper to remove doubled newlines
        ${pkgs.coreutils}/bin/cat ${dconf-ini} | ${pkgs.gnused}/bin/sed -e '/./b' -e :n -e 'N;s/\n$//;tn' | ${pkgs.dconf2nix}/bin/dconf2nix > $out
      '';
      dconf-nix = pkgs.stdenv.mkDerivation {
        name = "dconf-nix";
        builder = pkgs.bash;
        args = [ "${renderNix}" ];
      };
    in {
      packages = rec {
        dconf = dconf-nix;
        apply = pkgs.writeShellScriptBin "apply-dconf" ''
          ${pkgs.dconf}/bin/dconf load / < ${dconf-ini};
        '';
        gnome-install-extensions = gnome-extensions-script;
        gnome-desktop-setup = pkgs.writeShellScriptBin "gnome-desktop-setup" ''
          ## Install JetBrains nerd font
          mkdir -p ~/.local/share/fonts/ttf
          for file in "JetBrainsMono-Regular.ttf" "JetBrainsMonoNL-Regular.ttf"
          do
            if [[ ! -e ~/.local/share/fonts/ttf/$file ]]
            then
              ${pkgs.unzip}/bin/unzip -p ${jetbrains-font} fonts/ttf/$file > ~/.local/share/fonts/ttf/$file
            fi
          done
          ${pkgs.fontconfig}/bin/fc-cache -f -v ~/.local/share/fonts

          ## Install Nordic theme
          if [[ ! -d ~/.themes/Nordic ]]
          then
            mkdir -p ~/.themes/Nordic
            cp -r ${nordic}/* ~/.themes/Nordic
          fi

          ## Install extensions
          ${gnome-extensions-script}/bin/gnome-ext-install

          ## Apply dconf
          if [[ -v DBUS_SESSION_BUS_ADDRESS ]]; then
            export DCONF_DBUS_RUN_SESSION=""
          else
            export DCONF_DBUS_RUN_SESSION="${pkgs.dbus}/bin/dbus-run-session --dbus-daemon=${pkgs.dbus}/bin/dbus-daemon"
          fi
          $DCONF_BUS_RUN_SESSION ${pkgs.dconf}/bin/dconf load / < ${dconf-ini}

          ## Ensure ~/.nix-profile/share/applications is indexed by GNOME
          if ! grep -Eq "^XDG_DATA_DIRS" ~/.profile
          then
            export XDG_DATA_DIRS="$HOME/.nix-profile/share:$XDG_DATA_DIRS"
            printf "\nXDG_DATA_DIRS=\"$XDG_DATA_DIRS\"\n" >> ~/.profile
          fi
        '';
        vicinae = vicinae-sh;
        default = gnome-desktop-setup;
      };

      formatter = pkgs.alejandra;
    });
}
