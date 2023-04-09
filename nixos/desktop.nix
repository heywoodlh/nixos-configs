{ config, pkgs, home-manager, nur, ... }:

let
  bookmarks = pkgs.writeScriptBin "bookmarks" ''
    #!/usr/bin/env bash
    ## This script opens my bookmarks 
    xdg-open ~/opt/bookmarks/index.html
  '';
in {
  imports = [ 
    home-manager.nixosModule
    ../roles/linux-dotfiles.nix
  ];

  # Import nur as nixpkgs.overlays
  nixpkgs.overlays = [ 
    nur.overlay 
  ];

  boot = {
    kernelParams = [ "quiet" "splash" ];
    plymouth.enable = true;
    consoleLogLevel = 0;
    initrd.verbose = false;
  };

  # Enable sandbox
  nix.settings.sandbox = true;

  # Enable NetworkManager
  networking.networkmanager.enable = true;

  # Enable the X11 windowing system.
  services.xserver.enable = true;

  # Enable the GNOME Desktop Environment.
  services.xserver.displayManager.gdm.enable = true;
  services.xserver.displayManager.gdm.wayland = false;
  services.xserver.desktopManager.gnome = {
    enable = true;
  };

  # Exclude root from displayManager
  services.xserver.displayManager.hiddenUsers = [
    "root"
  ];

  # Enable Tailscale
  services.tailscale.enable = true;

  # Configure keymap in X11
  services.xserver = {
    layout = "us";
    xkbVariant = "";
  };

  # Enable CUPS to print documents.
  services.printing.enable = true;

  # Enable sound with pipewire.
  sound.enable = true;
  hardware.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
  };

  ## Experimental flag allows battery reporting for bluetooth devices
  systemd.services.bluetooth.serviceConfig.ExecStart = [
    ""
    "${pkgs.bluez}/libexec/bluetooth/bluetoothd --experimental"
  ];
  
  # Android debugging
  programs.adb.enable = true;

  # Seahorse (Gnome Keyring)
  programs.seahorse.enable = true;

  # Enable steam
  programs.steam.enable = true;
  
  services = {
    logind = {
      extraConfig = "RuntimeDirectorySize=10G";
    };
    unclutter = {
      enable = true;
      timeout = 10;
    };
    gnome = {
      gnome-browser-connector.enable = true;
      evolution-data-server.enable = true;
    };
    syncthing = {
      enable = true;
      user = "heywoodlh";
      dataDir = "/home/heywoodlh/Sync";
      configDir = "/home/heywoodlh/.config/syncthing";
    };
  };

  # Virtualbox
  users.extraGroups.vboxusers.members = [ "heywoodlh" ];
  users.extraGroups.disk.members = [ "heywoodlh" ];

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  # So that `nix search` works
  nix.extraOptions = '' 
    extra-experimental-features = nix-command flakes
  '';

  networking.firewall = {
    enable = true;
    checkReversePath = "loose";
    interfaces.shadow-internal.allowedTCPPortRanges = [ { from = 1714; to = 1764; } { from = 3131; to = 3131; } ];
    interfaces.shadow-external.allowedTCPPortRanges = [ { from = 1714; to = 1764; } { from = 3131; to = 3131;} ];
    interfaces.tailscale0.allowedTCPPortRanges = [ { from = 1714; to = 1764; } { from = 3131; to = 3131;} ];
    interfaces.shadow-internal.allowedUDPPortRanges = [  { from = 1714; to = 1764; } ];
    interfaces.shadow-external.allowedUDPPortRanges = [  { from = 1714; to = 1764; } ];
    interfaces.tailscale0.allowedUDPPortRanges = [  { from = 1714; to = 1764; } ];
  };

  fonts.fonts = with pkgs; [
    (nerdfonts.override { fonts = [ "Hack" "DroidSansMono" "Iosevka" ]; })
  ];

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.heywoodlh = {
    isNormalUser = true;
    description = "Spencer Heywood";
    extraGroups = [ "networkmanager" "wheel" "adbusers" ];
    shell = pkgs.powershell;
    packages = with pkgs; [
      acpi
      alacritty
      appimage-run
      aerc
      ansible
      automake
      awscli2
      bind
      bitwarden-cli
      bookmarks
      calcurse
      cargo
      cmake
      coreutils
      curl
      dante
      docker-client
      docker-compose
      gnome.dconf-editor
      go
      ffmpeg
      file
      firefox
      fzf
      gcc
      git
      github-cli
      gitleaks
      glib.dev
      glow
      gnome.gnome-tweaks
      gnomeExtensions.caffeine
      gnomeExtensions.gsconnect
      gnomeExtensions.hide-top-bar
      gnomeExtensions.pop-shell
      gnomeExtensions.tray-icons-reloaded
      gnomeExtensions.zilence
      gnumake
      gnupg
      go
      gotify-cli
      gotify-desktop
      guake
      htop
      inotify-tools
      jq
      k9s
      keyutils
      kind
      kubectl
      kubernetes-helm
      libarchive
      libnotify
      lima
      matrix-commander
      nixfmt
      nixos-generators
      nixos-install-tools
      nodejs
      nodePackages.cspell
      lefthook
      mosh
      neovim
      nim
      nordic
      olm
      openssl
      pandoc
      pass 
      (pass.withExtensions (ext: with ext; 
      [ 
        pass-otp 
      ])) 
      pciutils
      peru
      pinentry-curses
      pinentry-gnome
      pinentry-rofi
      plexamp
      pomerium-cli
      powershell
      procmail
      pwgen
      python310
      qemu-utils
      rbw
      rofi
      rofi-rbw
      scrot
      slack
      tcpdump
      terraform-docs
      texlive.combined.scheme-full
      tmux
      tree
      unzip
      uxplay
      vim
      virt-manager
      vultr-cli
      w3m
      wireguard-tools
      xautomation
      xclip
      xdotool
      zip
      zoom-us
      zsh
    ];
  };

  environment.homeBinInPath = true;
  environment.shells = [ pkgs.bashInteractive pkgs.powershell "/etc/profiles/per-user/heywoodlh/bin/tmux" ];

  # Bluetooth settings
  hardware.bluetooth.settings = {
    # Necessary for Airpods
    General = { ControllerMode = "dual"; } ;
  };

  # Home-manager settings specific for Linux
  home-manager.users.heywoodlh = {
    home.stateVersion = "22.11";
    programs.rbw.settings = {
      email = "l.spencer.heywood@protonmail.com";
      pinentry = "pinentry-gnome3";
    };

    # Dconf/GNOME settings
    dconf.settings = {
      "org/gnome/desktop/input-sources" = {
        xkb-options = ["caps:super"];
      };
      "apps/guake/general" = {
        abbreviate-tab-names = false;
        compat-delete = "delete-sequence";
        default-shell = "/etc/profiles/per-user/heywoodlh/bin/tmux";
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
        quick-open-command-line = "gedit %(file_path)s";
        restore-tabs-notify = false;
        restore-tabs-startup = false;
        save-tabs-when-changed = false;
        schema-version = "3.9.0";
        scroll-keystroke = true;
        start-at-login = true;
        use-default-font = false;
        use-login-shell = false;
        use-popup = false;
        use-scrollbar = true;
        use-trayicon = false;
        window-halignment = 0;
        window-height = 50;
        window-losefocus = false;
        window-refocus = false;
        window-tabbar = false;
        window-width = 100;
      };
      "apps/guake/keybindings/global" = {
        show-hide = "<Primary>grave";
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
        transparency = 82;
      };
      "apps/guake/style/font" = {
        allow-bold = true;
        palette = "#3B3B42425252:#BFBF61616A6A:#A3A3BEBE8C8C:#EBEBCBCB8B8B:#8181A1A1C1C1:#B4B48E8EADAD:#8888C0C0D0D0:#E5E5E9E9F0F0:#4C4C56566A6A:#BFBF61616A6A:#A3A3BEBE8C8C:#EBEBCBCB8B8B:#8181A1A1C1C1:#B4B48E8EADAD:#8F8FBCBCBBBB:#ECECEFEFF4F4:#D8D8DEDEE9E9:#2E2E34344040";
        palette-name = "Nord";
        style = "IosevkaTerm Nerd Font Mono Regular 14";
      };
      "org/gnome/shell" = {
        disable-user-extensions = false;
        disabled-extensions = ["disabled"];
        enabled-extensions = [
          "native-window-placement@gnome-shell-extensions.gcampax.github.com"
          "pop-shell@system76.com"
          "caffeine@patapon.info"
          "hidetopbar@mathieu.bidon.ca"
          "gsconnect@andyholmes.github.io"
        ];
        favorite-apps = ["firefox.desktop" "alacritty.desktop"];
        had-bluetooth-devices-setup = true;
        remember-mount-password = false;
        welcome-dialog-last-shown-version = "42.4";
      };
      "org/gnome/mutter" = {
        dynamic-workspaces = false;
      };
      "org/gnome/shell/extensions/hidetopbar" = {
        enable-active-window = false;
        enable-intellihide = false; 
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
        close = "['<Super>q', '<Alt>F4']";
        maximize = ["disabled"];
        minimize = "['<Super>comma']";
        move-to-monitor-down = ["disabled"];
        move-to-monitor-left = ["disabled"];
        move-to-monitor-right = ["disabled"];
        move-to-monitor-up = ["disabled"];
        move-to-workspace-down = ["disabled"];
        move-to-workspace-up = ["disabled"];
        switch-to-workspace-left = ["<Super>bracketleft"];
        switch-to-workspace-right = ["<Super>bracketright"];
        switch-input-source = ["disabled"];
        switch-input-source-backward = ["disabled"];
        toggle-maximized = "['<Super>m']";
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
      };
      "org/gnome/desktop/notifications" = {
        show-in-lock-screen = false;
      };
      "org/gnome/desktop/peripherals/touchpad" = {
        tap-to-click = true;
        two-finger-scrolling-enabled = true;
      };
      "org/gnome/settings-daemon/plugins/media-keys" = {
        next = [ "<Shift><Control>n" ];
        previous = [ "<Shift><Control>p" ];
        play = [ "<Shift><Control>space" ];
        custom-keybindings = [
          "/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom0/"
          "/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom1/"
          "/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom2/"
          "/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom3/"
          "/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom4/"
          "/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom5/"
          "/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom6/"
        ];
      };
      "org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom0" = {
        name = "terminal super";
        command = "alacritty";
        binding = "<Super>Return";
      };
      "org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom1" = {
        name = "terminal ctrl_alt";
        command = "alacritty";
        binding = "<Ctrl><Alt>t";
      };
      "org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom2" = {
        name = "rofi-rbw";
        command = "rofi-rbw --action copy";
        binding = "<Ctrl><Super>s";
      };
      "org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom3" = {
        name = "rofi launcher";
        command = "rofi -theme nord -show run -display-run 'run: '";
        binding = "<Super>space";
      };
      "org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom4" = {
        binding = "<Ctrl><Shift>s";
        command = "scrot /home/heywoodlh/Documents/screenshots/scrot-+%Y-%m-%d_%H_%M_%S.png -s -e 'xclip -selection clipboard -t image/png -i $f'";
        name = "screenshot";
      };
      "org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom5" = {
        binding = "<Shift><Control>e";
        command = "/home/heywoodlh/bin/vim-ime.py --cmd 'alacritty -o window.dimensions.columns=60 window.dimensions.lines=8 -e vim' --outfile '/home/heywoodlh/tmp/vim-ime.txt'";
        name = "vim-ime";
      };
      "org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom6" = {
        binding = "<Shift><Control>b";
        command = "bash -c 'notify-send $(acpi -b | grep -Eo [0-9]+%)'";
        name = "battpop";
      };
    };

    # Firefox config
    programs.firefox = {
      enable = true;
      package = pkgs.firefox.override {
        cfg = {
          enableGnomeExtensions = true;
        };
      };
      profiles.default = {
        search.force = true; # This is required so the build won't fail each time
        # View extensions here: https://github.com/nix-community/nur-combined/blob/master/repos/rycee/pkgs/firefox-addons/generated-firefox-addons.nix
        extensions = with pkgs.nur.repos.rycee.firefox-addons; [
          bitwarden
          darkreader
          firenvim
          gnome-shell-integration
          okta-browser-plugin
          privacy-badger
          private-relay
          redirector
          ublock-origin
          vimium
        ]; 
        userChrome = ''
          /* * Do not remove the @namespace line -- it's required for correct functioning */
          /* set default namespace to XUL */
          @namespace url("http://www.mozilla.org/keymaster/gatekeeper/there.is.only.xul");

          /* Remove Back button when there's nothing to go Back to */
          #back-button[disabled="true"] { display: none; }

          /* Remove Forward button when there's nothing to go Forward to */
          #forward-button[disabled="true"] { display: none; }

          /* Remove Home button (never use it) */
          #home-button { display: none; }

          .titlebar-spacer {
	    display: none !important;
          }
        
          /* Remove import bookmarks button */ 
          #import-button {
            display: none;
          } 
          
          /* Remove bookmark toolbar */
          toolbarbutton.bookmark-item:not(.subviewbutton) {
            display: none;
          }

          /* Remove whitespace in toolbar */
          #nav-bar toolbarpaletteitem[id^="wrapper-customizableui-special-spring"], #nav-bar toolbarspring {
            display: none;
          }

          /* Hide dumb Firefox View button */
          #firefox-view-button {
            visibility: hidden;
          }

          /* Hide Firefox tab icon */
          .tab-icon-image {
            display: none;
          } 

          /* Linux stuff to keep GNOME system theme */
          .titlebar-min {
            appearance: auto !important;
            -moz-default-appearance: -moz-window-button-minimize !important;
          }
          
          .titlebar-max {
            appearance: auto !important;
            -moz-default-appearance: -moz-window-button-maximize !important;  
          }
          
          .titlebar-restore {
            appearance: auto !important;
            -moz-default-appearance: -moz-window-button-restore !important;
          }
          
          .titlebar-close {
            appearance: auto !important;
            -moz-default-appearance: -moz-window-button-close !important;
          }
          
          .titlebar-button{
            list-style-image: none !important;
          } 
        '';
        isDefault = true;
        name = "default";
        search.default = "DuckDuckGo";
        settings = {
          "app.shield.optoutstudies.enabled" = false;
          "browser.bookmarks.restore_default_bookmarks" = false;
          "browser.bookmarks.showMobileBookmarks" = false;
          "browser.compactmode.show" = true;
          "browser.formfill.enable" = false;
          "browser.newtabpage.activity-stream.feeds.section.topstories" = false;
          "browser.newtabpage.activity-stream.feeds.telemetry" = false;
          "browser.newtabpage.activity-stream.feeds.topsites" = false;
          "browser.newtabpage.activity-stream.improvesearch.topSiteSearchShortcuts.havePinned" = "duckduckgo";
          "browser.newtabpage.activity-stream.showSponsored" = false;
          "browser.newtabpage.activity-stream.telemetry" = false;
          "browser.ping-centre.telemetry" = false;
          "browser.search.isUS" = true;
          "browser.search.suggest.enabled" = false;
          "browser.tabs.drawInTitlebar" = true;
          "browser.urlbar.quicksuggest.scenario" = "offline";
          "browser.urlbar.suggest.engines" = false;
          "browser.urlbar.suggest.quicksuggest.nonsponsored" = false;
          "browser.urlbar.suggest.quicksuggest.sponsored" = false;
          "browser.urlbar.suggest.topsites" = false;
          "experiments.activeExperiment" = false;
          "experiments.enabled" = false;
          "experiments.supported" = false;
          "extensions.activeThemeID" = "firefox-compact-dark@mozilla.org";
          "extensions.formautofill.addresses.enabled" = false;
          "extensions.formautofill.creditCards.enabled" = false;
          "extensions.pocket.enabled" = false;
          "extensions.pocket.showHome" = false;
          "extensions.webextensions.restrictedDomains" = "";
          "network.allow-experiments" = false;
          "network.proxy.no_proxies_on" = "localhost,127.0.0.1,.lan,.wireguard,.kube,.heywoodlh.tech,google.com,.okta.com,okta.com,.amazon.com,amazon.com,.mychg.com,mychg.com,chghealthcare.com,office.com,.office.com,microsoft.com,.microsoft.com,.atlassian.com,atlassian.com,jira.com,.jira.com,amazonaws.com,.amazonaws.com,10.0.0.0/8,172.16.0.0/12,192.168.0.0/16,paypal.com,.paypal.com,unity.com,awsapps.com,.awsapps.com,.wired,chat.openai.com,heywoodlh.tech";
          "network.proxy.socks" = "10.64.0.1";
          "network.proxy.socks_port" = 1080;
          "network.proxy.type" = 1;
          "signon.rememberSignons" = false;
          "signon.rememberSignons.visibilityToggle" = false;
          "svg.context-properties.content.enabled" = true;
          "toolkit.legacyUserProfileCustomizations.stylesheets" = true;
          "toolkit.telemetry.archive.enabled" = false;
          "toolkit.telemetry.bhrPing.enabled" = false;
          "toolkit.telemetry.coverage.opt-out" = true;
          "toolkit.telemetry.enabled" = false;
          "toolkit.telemetry.firstShutdownPing.enabled" = false;
          "toolkit.telemetry.hybridContent.enabled" = false;
          "toolkit.telemetry.newProfilePing.enabled" = false;
          "toolkit.telemetry.prompted" = 2;
          "toolkit.telemetry.rejected" = true;
          "toolkit.telemetry.reportingpolicy.firstRun" = false;
          "toolkit.telemetry.shutdownPingSender.enabled" = false;
          "toolkit.telemetry.unified" = false;
          "toolkit.telemetry.unifiedIsOptIn" = false;
          "toolkit.telemetry.updatePing.enabled" = false;
        };
      };
    }; 
    # End Firefox config
  };
  # End home-manager config
}
