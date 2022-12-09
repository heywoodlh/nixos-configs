{ config, pkgs, ... }:

let
  unstable = import <nixos-unstable> { config = { allowUnfree = true; }; };
in {

  boot.kernelParams = [ "quiet" "splash" ];

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
    docker.rootless = {
      enable = true;
    };
  };

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    #vim
  ];

  # So that `nix search` works
  nix.extraOptions = '' 
    extra-experimental-features = nix-command flakes
  '';

  networking.firewall = {
    enable = true;
    checkReversePath = "loose";
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
      aerc
      ansible
      automake
      awscli2
      bind
      bitwarden
      bitwarden-cli
      calcurse
      cargo
      cider
      cmake
      coreutils
      curl
      dante
      docker-compose
      gnome.dconf-editor
      go
      evolution
      evolution-data-server
      evolution-ews
      fetchmail
      ffmpeg
      file
      firefox
      fzf
      gcc
      git
      github-cli
      gitleaks
      glib.dev
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
      libnotify
      libreoffice
      lima
      losslesscut-bin
      matrix-commander
      moonlight-qt
      nodejs
      lefthook
      mosh
      neofetch
      nerdfonts
      nim
      nordic
      openssl
      pandoc
      pass 
      (pass.withExtensions (ext: with ext; 
      [ 
        pass-otp 
      ])) 
      pciutils
      peru
      pinentry-gnome
      plex-media-player
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
      scrot
      signal-desktop
      slack
      tcpdump
      teams
      terraform
      thunderbird
      tmux
      vim
      vultr-cli
      w3m
      wireguard-tools
      xautomation
      xclip
      xdotool
      zoom-us
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
        disabled-extensions = "@as []";
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
        activate-window-menu = "@as []";
        toggle-message-tray = "@as []";
        close = "['<Super>q', '<Alt>F4']";
        maximize = "@as []";
        minimize = "['<Super>comma']";
        move-to-monitor-down = "@as []";
        move-to-monitor-left = "@as []";
        move-to-monitor-right = "@as []";
        move-to-monitor-up = "@as []";
        move-to-workspace-down = "@as []";
        move-to-workspace-up = "@as []";
        toggle-maximized = "['<Super>m']";
        unmaximize = "@as []";
      };
      "org/gnome/desktop/wm/preferences" = {
        button-layout = "close,minimize,maximize:appmenu";
        num-workspaces = 10;
      };
      "org/gnome/shell/extensions/pop-shell" = {
        focus-right = "@as []";
        tile-by-default = true;
        tile-enter = "@as []";
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
        command = "scrot '/tmp/scrot-+%Y-%m-%d_%H_%M_%S.png' -s -e 'xclip -selection clipboard -t image/png -i $f'";
        name = "screenshot";
      };
      "org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom5" = {
        binding = "<Shift><Control>e";
        command = "/home/heywoodlh/bin/vim-ime.py --cmd 'alacritty -o window.dimensions.columns=60 window.dimensions.lines=8 -e vim' --outfile '/home/heywoodlh/tmp/vim-ime.txt'";
        name = "vim-ime";
      };
    };
  };
}
