# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, ... }:

{
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
      ./custom.nix
      <home-manager/nixos> 
    ];

  # Bootloader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.loader.efi.efiSysMountPoint = "/boot/efi";

  # Setup keyfile
  boot.initrd.secrets = {
    "/crypto_keyfile.bin" = null;
  };

  # Enable swap on luks
  boot.initrd.luks.devices."luks-a600cf6f-b6a7-4e9c-a20b-d370b524f907".device = "/dev/disk/by-uuid/a600cf6f-b6a7-4e9c-a20b-d370b524f907";
  boot.initrd.luks.devices."luks-a600cf6f-b6a7-4e9c-a20b-d370b524f907".keyFile = "/crypto_keyfile.bin";

  networking.hostName = "nix-xps"; # Define your hostname.

  # Enable networking
  networking.networkmanager.enable = true;

  # Set your time zone.
  time.timeZone = "America/Denver";

  # Select internationalisation properties.
  i18n.defaultLocale = "en_US.utf8";

  # Enable the X11 windowing system.
  services.xserver.enable = true;

  # Enable the GNOME Desktop Environment.
  services.xserver.displayManager.gdm.enable = true;
  services.xserver.displayManager.gdm.wayland = false;
  services.xserver.desktopManager.gnome = {
    enable = true;
  };

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
    # If you want to use JACK applications, uncomment this
    #jack.enable = true;
  };

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.heywoodlh = {
    isNormalUser = true;
    description = "Spencer Heywood";
    extraGroups = [ "networkmanager" "wheel" ];
    shell = pkgs.powershell;
    packages = with pkgs; [
      aerc
      ansible
      automake
      awscli2
      bind
      bitwarden
      bitwarden-cli
      cider
      coreutils
      curl
      dante
      docker-compose
      gnome.dconf-editor
      evolution
      evolution-data-server
      evolution-ews
      file
      firefox
      fzf
      gcc
      git
      gitleaks
      glib.dev
      gnome.gnome-tweaks
      gnomeExtensions.caffeine
      gnomeExtensions.gsconnect
      gnomeExtensions.pop-shell
      gnumake
      gnupg
      gotify-cli
      guake
      inotify-tools
      jq
      k9s
      keyutils
      kitty
      kubectl
      libnotify
      lima
      matrix-commander
      moonlight-qt
      lefthook
      mosh
      neofetch
      nerdfonts
      nordic
      pass 
      (pass.withExtensions (ext: with ext; 
      [ 
        pass-otp 
      ])) 
      peru
      pinentry-gnome
      powershell
      qemu-utils
      rbw
      realvnc-vnc-viewer
      remmina
      rofi
      rofi-rbw
      scrot
      signal-desktop
      slack
      tcpdump
      teams
      thunderbird
      tmux
      vim
      wireguard-tools
      xclip
      xdotool
      zoom-us
    ];
  };

  services = {
    syncthing = {
      enable = true;
      user = "heywoodlh";
      dataDir = "/home/heywoodlh/Sync";
      configDir = "/home/heywoodlh/.config/syncthing";
    };
    unclutter = {
      enable = true;
      timeout = 10;
    };
    gnome = {
      chrome-gnome-shell.enable = true;
      evolution-data-server.enable = true;
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
  #  vim # Do not forget to add an editor to edit configuration.nix! The Nano editor is also installed by default.
  #  wget
  ];

  # So that `nix search` works
  nix.extraOptions = '' 
    extra-experimental-features = nix-command flakes
  '';

  networking.firewall = {
    enable = true;
    checkReversePath = "loose";
    ## Allow GSConnect over Tailscale
    interfaces."tailscale0" = {
      allowedTCPPortRanges = [
        { from = 1714; to = 1764; }
      ];
      allowedUDPPortRanges = [
        { from = 1714; to = 1764; }
      ];
    };
    ## Allow GSConnect over Wireguard
    interfaces."shadow-internal" = {
      allowedTCPPortRanges = [
        { from = 1714; to = 1764; }
      ];
      allowedUDPPortRanges = [
        { from = 1714; to = 1764; }
      ];
    };
    ## Allow GSConnect over Wireguard
    interfaces."shadow-external" = {
      allowedTCPPortRanges = [
        { from = 1714; to = 1764; }
      ];
      allowedUDPPortRanges = [
        { from = 1714; to = 1764; }
      ];
    };
  };
  system.stateVersion = "22.05";

  # Home-manager settings
  home-manager.users.heywoodlh = {
    dconf.settings = {
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
        custom-keybindings = [
          "/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom0/"
          "/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom1/"
          "/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom2/"
          "/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom3/"
          "/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom4/"
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
        name = "bwmenu";
        command = "/home/heywoodlh/bin/bwmenu";
        binding = "<Ctrl><Super>s";
      };
      "org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom3" = {
        name = "rofi launcher";
        command = "rofi -theme nord -show run -display-run 'run: '";
        binding = "<Super>space";
      };
      "org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom4" = {
        binding = "<Ctrl><Shift>s";
        command = "scrot -s -e 'xclip -selection clipboard -t image/png -i $f'";
        name = "screenshot";
      };
    };
  };
}
