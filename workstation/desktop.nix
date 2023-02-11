{ config, pkgs, ... }:

let
  unstableTarball =
    fetchTarball
      https://github.com/NixOS/nixpkgs/archive/nixos-unstable.tar.gz;
in {

  imports = [ 
    (import "${builtins.fetchTarball https://github.com/nix-community/home-manager/archive/release-22.11.tar.gz}/nixos")
  ];

  nixpkgs.config = {
    packageOverrides = pkgs: {
      unstable = import unstableTarball {
        config = config.nixpkgs.config;
      };
    };
  };

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

  # Set DNS
  networking.nameservers = [ "10.50.50.1" ];
  environment.etc = {
    "resolv.conf".text = "nameserver 10.50.50.1\n";
  }; 

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
    media-session.config.bluez-monitor.rules = [
      {
        # Matches all cards
        matches = [ { "device.name" = "~bluez_card.*"; } ];
        actions = {
          "update-props" = {
            "bluez5.reconnect-profiles" = [ "hfp_hf" "hsp_hs" "a2dp_sink" ];
            # mSBC is not expected to work on all headset + adapter combinations.
            "bluez5.msbc-support" = true;
            # SBC-XQ is not expected to work on all headset + adapter combinations.
            "bluez5.sbc-xq-support" = true;
          };
        };
      }
      {
        matches = [
          # Matches all sources
          { "node.name" = "~bluez_input.*"; }
          # Matches all outputs
          { "node.name" = "~bluez_output.*"; }
        ];
        actions = {
          "node.pause-on-idle" = false;
        };
      }
    ];
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

  virtualisation = {
    podman = {
      enable = true;
      dockerCompat = true;
    };
    virtualbox.host.enable = true;
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

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.heywoodlh = {
    isNormalUser = true;
    description = "Spencer Heywood";
    extraGroups = [ "networkmanager" "wheel" "adbusers" ];
    shell = pkgs.powershell;
    packages = with pkgs; [
      abootimg
      alacritty
      appimage-run
      unstable.aerc
      ansible
      argocd
      automake
      awscli2
      bind
      bitwarden
      bitwarden-cli
      brave
      calcurse
      cargo
      unstable.cider
      cmake
      coreutils
      curl
      dante
      docker-compose
      gnome.dconf-editor
      go
      gomuks
      evolution
      evolution-data-server
      evolution-ews
      ffmpeg
      file
      firefox
      freshfetch
      fzf
      gcc
      git
      github-cli
      gitleaks
      glib.dev
      glow
      gnome.gnome-boxes
      gnome.gnome-tweaks
      gnomeExtensions.caffeine
      gnomeExtensions.gsconnect
      gnomeExtensions.hide-top-bar
      gnomeExtensions.pop-shell
      gnomeExtensions.tray-icons-reloaded
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
      kitty
      kubectl
      kubernetes-helm
      libarchive
      libnotify
      libreoffice
      lima
      lutris
      matrix-commander
      moonlight-qt
      nixos-generators
      nixos-install-tools
      nodejs
      lefthook
      mosh
      neovim
      nerdfonts
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
      plex-media-player
      podman-compose
      procmail
      unstable.powershell
      pwgen
      python310Full
      qemu-utils
      unstable.rbw
      realvnc-vnc-viewer
      remmina
      rofi
      unstable.rofi-rbw
      rpi-imager
      unstable.rustdesk
      scrot
      signal-desktop
      slack
      tcpdump
      teams
      terraform-docs
      texlive.combined.scheme-full
      thunderbird
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

  # Home-manager settings
  home-manager.users.heywoodlh = {
    home.stateVersion = "22.11";
    dconf.settings = {
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
        favorite-apps = ["firefox.desktop" "kitty.desktop"];
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
          "/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom7/"
          "/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom8/"
          "/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom9/"
          "/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom10/"
          "/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom11/"
        ];
      };
      "org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom0" = {
        name = "kitty super";
        command = "kitty -e tmux";
        binding = "<Super>Return";
      };
      "org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom1" = {
        name = "kitty ctrl_alt";
        command = "kitty -e tmux";
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
        binding = "<Shift><Control>h";
        command = "xdotool mousemove_relative -- -20 0";
        name = "move mouse left";
      };
      "org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom7" = {
        binding = "<Shift><Control>l";
        command = "xdotool mousemove_relative -- 20 0";
        name = "move mouse right";
      };
      "org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom8" = {
        binding = "<Shift><Control>j";
        command = "xdotool mousemove_relative -- 0 20";
        name = "move mouse down";
      };
      "org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom9" = {
        binding = "<Shift><Control>k";
        command = "xdotool mousemove_relative -- 0 -20";
        name = "move mouse up";
      };
      "org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom10" = {
        binding = "<Control>bracketleft";
        command = "xdotool click --clearmodifiers 1";
        name = "left click";
      };
      "org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom11" = {
        binding = "<Control>bracketright";
        command = "xdotool click --clearmodifiers 3";
        name = "right click";
      };
    };
  };
}
