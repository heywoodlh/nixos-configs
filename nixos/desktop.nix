{ config, pkgs, lib, home-manager,
  nur, nixpkgs-stable, nixpkgs-lts,
  myFlakes, flatpaks,
  light-wallpaper, dark-wallpaper,
  ts-warp-nixpkgs, qutebrowser,
  ghostty,
  ... }:

let
  system = pkgs.system;
  pkgs-stable = import nixpkgs-stable {
    inherit system;
    config.allowUnfree = true;
  };
in {
  imports = [
    ./base.nix
    ./roles/desktop/user-icon.nix
    ./roles/virtualization/libvirt.nix
  ];

  nixpkgs.overlays = [
    # Import nur as nixpkgs.overlays
    nur.overlays.default
  ];

  boot = {
    kernelParams = [ "quiet" "splash" ];
    plymouth.enable = true;
    consoleLogLevel = 0;
    initrd.verbose = false;
  };

  # Networking
  networking = {
    #nftables.enable = true;
    networkmanager.enable = true;
  };

  # Enable the X11 windowing system.
  services.xserver.enable = true;

  # Enable nord-themed lightdm
  #services.xserver.displayManager.lightdm = {
  #  enable = false;
  #  background = dark-wallpaper;
  #  greeters.gtk = {
  #    enable = true;
  #    theme = {
  #      name = "Nordic-darker";
  #      package = pkgs.nordic;
  #    };
  #  };
  #};

  # Enable GNOME
  services.xserver.desktopManager.gnome.enable = true;
  services.xserver.displayManager.gdm.enable = true;
  boot.tmp.cleanOnBoot = true;

  # Enable Sway (home-manager config manages details)
  #programs.sway = {
  #  enable = true;
  #  wrapperFeatures = {
  #    base = true;
  #    gtk = true;
  #  };
  #  xwayland.enable = true;
  #};

  # Enable kde connect
  programs.kdeconnect = {
    enable = true;
    package = pkgs.gnomeExtensions.gsconnect;
  };
  networking.firewall = {
    interfaces.tailscale0.allowedTCPPortRanges = [ { from = 1714; to = 1764; } { from = 3131; to = 3131;} ];
    interfaces.tailscale0.allowedUDPPortRanges = [ { from = 1714; to = 1764; } ];
  };

  # Enable Tailscale
  services.tailscale = {
    enable = true;
    extraSetFlags = [
      "--accept-routes"
    ];
  };

  # Configure keymap in X11
  services.xserver.xkb = {
    layout = "us";
    variant = "";
  };

  services.printing.enable = true;

  services.avahi = {
    enable = true;
    nssmdns4 = true;
    openFirewall = true; # For wifi printers
  };
  # For scanning documents
  hardware.sane.enable = true;
  users.extraGroups.lp.members = [ "heywoodlh" ];
  users.extraGroups.scanner.members = [ "heywoodlh" ];

  # Enable sound with pipewire.
  #sound.enable = true;
  services.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
  };

  ## Bluetooth
  hardware.bluetooth = {
    enable = true;
    settings = {
      # Necessary for Airpods
      General = { ControllerMode = "dual"; } ;
    };
  };

  # Android debugging
  programs.adb.enable = true;

  # iPhone usb support
  services.usbmuxd.enable = true;

  # Seahorse (Gnome Keyring)
  programs.seahorse.enable = true;

  services = {
    logind = {
      extraConfig = "RuntimeDirectorySize=10G";
    };
    syncthing = {
      enable = true;
      user = "heywoodlh";
      dataDir = "/home/heywoodlh/Sync";
      configDir = "/home/heywoodlh/.config/syncthing";
    };
  };

  # Virtualization
  virtualisation = {
    docker.rootless = {
      package = pkgs-stable.docker;
      enable = true;
      setSocketVariable = true;
    };
  };
  users.extraGroups.vboxusers.members = [ "heywoodlh" ];
  users.extraGroups.disk.members = [ "heywoodlh" ];
  users.extraGroups.video.members = [ "heywoodlh" ];

  # Allow x86 packages to be installed on aarch64
  nixpkgs.config.allowUnsupportedSystem = true;

  networking.firewall = {
    enable = true;
    checkReversePath = "loose";
  };

  fonts.packages = with pkgs.nerd-fonts; [
    jetbrains-mono
  ];

  users.users.heywoodlh = {
    isNormalUser = true;
    description = "Spencer Heywood";
    extraGroups = [ "networkmanager" "wheel" "adbusers" ];
    shell = pkgs.bashInteractive;
    # users.users.<name>.icon not a NixOS option
    # made possible with ./roles/desktop/user-icon.nix
    icon = builtins.fetchurl {
      url = "https://avatars.githubusercontent.com/u/18178614?v=4";
      sha256 = "sha256:02937kl4qmj29gms9r06kckq8fjpvl40bqi9vpxipwa4xy0wrymg";
    };
    homeMode = "755";
  };

  environment.homeBinInPath = true;
  environment.shells = [
    pkgs.bashInteractive
  ];

  # Desktop packages
  environment.systemPackages = [
    pkgs.busybox
    pkgs.lsof
    pkgs.libimobiledevice # for iPhone
    pkgs.idevicerestore # for iPhone
    pkgs.gnome-screenshot
    pkgs.ifuse
    pkgs.usbutils
    myFlakes.packages.${system}.tmux
    myFlakes.packages.${system}.vim
  ];

  # Disable wait-online service for Network Manager
  systemd.services.NetworkManager-wait-online.enable = false;

  programs._1password-gui = {
    enable = true;
    # Certain features, including CLI integration and system authentication support,
    # require enabling PolKit integration on some desktop environments (e.g. Plasma).
    polkitPolicyOwners = [ "heywoodlh" ];
  };

  # Home-manager configs
  home-manager = {
    extraSpecialArgs = {
      inherit myFlakes;
      inherit nixpkgs-lts;
      inherit nixpkgs-stable;
      inherit light-wallpaper;
      inherit dark-wallpaper;
      inherit ts-warp-nixpkgs;
      inherit qutebrowser;
      inherit ghostty;
    };
    backupFileExtension = ".bak";
    users.heywoodlh = { ... }: {
      imports = [
        ../home/linux.nix
        ../home/desktop.nix # base desktop.nix
        ../home/linux/desktop.nix # linux-specific desktop.nix
        flatpaks.homeManagerModules.declarative-flatpak
        (import myFlakes.packages.${system}.gnome-dconf)
      ];
      home.packages = [
        myFlakes.packages.${system}.git
      ];
    };
  };

  programs.nix-index.enable = true;
  programs.command-not-found.enable = false;

  # Automatically garbage collect
  nix.gc = {
    automatic = true;
    dates = "daily";
    options = "--delete-older-than 7d";
  };

  # Enable ergodox ez/moonlander keyboard tools
  hardware.keyboard.zsa.enable = true;

  # Thunderbolt 3
  services.hardware.bolt.enable = true;

  # Use seahorse ssh-agent
  system.activationScripts.symlink-ssh-agent = {
    text = ''
      mkdir -p /home/heywoodlh/.ssh && chown -R heywoodlh /home/heywoodlh/.ssh
      ln -s /run/user/1000/keyring/ssh /home/heywoodlh/.ssh/agent.sock &> /dev/null || true
    '';
  };
}
