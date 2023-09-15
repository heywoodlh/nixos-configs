{ config, pkgs, lib, home-manager,
  nur, vim-configs, git-configs,
  hyprland, nixpkgs-unstable,
  nixpkgs-backports, wezterm-configs,
  fish-configs, ... }:

let
  system = pkgs.system;
  pkgs-unstable = nixpkgs-unstable.legacyPackages.${system};
  pkgs-backports = nixpkgs-backports.legacyPackages.${system};
in {
  imports = [
    home-manager.nixosModules.home-manager
    ./roles/desktop/user-icon.nix
  ];

  home-manager.useGlobalPkgs = true;

  nixpkgs.overlays = [
    # Import nur as nixpkgs.overlays
    nur.overlay
  ];

  boot = {
    kernelPackages = pkgs.linuxPackages_zen;
    kernelParams = [ "quiet" "splash" ];
    plymouth.enable = true;
    consoleLogLevel = 0;
    initrd.verbose = false;
  };

  nix.settings = {
    sandbox = true;
    # Automatically optimize store for better storage
    auto-optimise-store = true;
    substituters = [
      #"https://hyprland.cachix.org"
      "http://100.108.77.60:5000" # nix-nvidia
      "https://nix-community.cachix.org"
      "https://cache.nixos.org/"
    ];
    trusted-users = [
      "heywoodlh"
    ];
    trusted-public-keys = [
      #"hyprland.cachix.org-1:a7pgxzMz7+chwVL3/pzj6jIBMioiJM7ypFP8PwtkuGc="
      "binarycache.heywoodlh.io:hT9E35rju+9L2CE/SDGUsytJtIZJfqVma7B7cp7Jym4=" # nix-nvidia
      "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
    ];
  };

  # Networking
  networking = {
    nftables.enable = true;
    networkmanager.enable = true;
  };

  # Enable the X11 windowing system.
  services.xserver.enable = true;

  # Enable nord-themed lightdm
  #services.xserver.displayManager.lightdm = {
  #  enable = false;
  #  background = builtins.fetchurl {
  #    url = "https://raw.githubusercontent.com/NixOS/nixos-artwork/ac04f06feb980e048b4ab2a7ca32997984b8b5ae/wallpapers/nix-wallpaper-dracula.png";
  #    sha256 = "sha256:07ly21bhs6cgfl7pv4xlqzdqm44h22frwfhdqyd4gkn2jla1waab";
  #  };
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
  services.xserver.displayManager.gdm = {
    enable = true;
  };

  # Enable hyprland
  #programs.hyprland = {
  #  enable = true;
  #  xwayland.enable = true;
  #};
  #security.pam.services.swaylock.text = "auth include login";
  #hardware.brillo.enable = true;

  # Enable kde connect
  programs.kdeconnect.enable = true;
  networking.firewall = {
    interfaces.tailscale0.allowedTCPPortRanges = [ { from = 1714; to = 1764; } { from = 3131; to = 3131;} ];
    interfaces.tailscale0.allowedUDPPortRanges = [  { from = 1714; to = 1764; } ];
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
  services.printing = {
    enable = true;
    drivers = [ pkgs.hplipWithPlugin ];
  };
  services.avahi = {
    enable = true;
    nssmdns = true;
    openFirewall = true; # For wifi printers
  };
  # For scanning documents
  hardware.sane = {
    enable = true;
    extraBackends = [ pkgs.hplipWithPlugin ];
  };
  users.extraGroups.lp.members = [ "heywoodlh" ];
  users.extraGroups.scanner.members = [ "heywoodlh" ];

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
      package = pkgs-backports.docker;
      enable = true;
      setSocketVariable = true;
    };
  };
  users.extraGroups.vboxusers.members = [ "heywoodlh" ];
  users.extraGroups.disk.members = [ "heywoodlh" ];
  users.extraGroups.video.members = [ "heywoodlh" ];

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;
  # Allow x86 packages to be installed on aarch64
  nixpkgs.config.allowUnsupportedSystem = true;

  networking.firewall = {
    enable = true;
    checkReversePath = "loose";
  };

  fonts.fonts = with pkgs; [
    (nerdfonts.override { fonts = [ "Hack" "DroidSansMono" "Iosevka" "JetBrainsMono" ]; })
  ];

  users.users.heywoodlh = {
    isNormalUser = true;
    description = "Spencer Heywood";
    extraGroups = [ "networkmanager" "wheel" "adbusers" ];
    shell = pkgs.bash;
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
    pkgs.libimobiledevice # for iPhone
    pkgs.idevicerestore # for iPhone
    pkgs.ifuse
    pkgs.usbutils
    vim-configs.defaultPackage.${system}
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
      inherit fish-configs;
      inherit wezterm-configs;
    };
    users.heywoodlh = { ... }: {
      imports = [
        ../roles/home-manager/linux.nix
        ../roles/home-manager/desktop.nix # base desktop.nix
        ../roles/home-manager/linux/desktop.nix # linux-specific desktop.nix
        ../roles/home-manager/linux/gnome-desktop.nix
        #hyprland.homeManagerModules.default
        #../roles/home-manager/linux/hyprland.nix
      ];
      home.packages = [
        git-configs.packages.${system}.git
      ];
      home.file."bin/nixos-switch" = {
        enable = true;
        executable = true;
        text = ''
          #!/usr/bin/env bash
          [[ -d ~/opt/nixos-configs ]] || git clone https://github.com/heywoodlh/nixos-configs
          git -C ~/opt/nixos-configs pull origin master
          /run/wrappers/bin/sudo nixos-rebuild switch --flake ~/opt/nixos-configs#$(hostname) --impure $@
        '';
      };
    };
  };

  # Automatically garbage collect
  nix.gc = {
    automatic = true;
    dates = "daily";
    options = "--delete-older-than 7d";
  };
}
