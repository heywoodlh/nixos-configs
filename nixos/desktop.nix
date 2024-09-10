{ config, pkgs, lib, home-manager,
  nur, hyprland, nixpkgs-backports,
  nixpkgs-stable, nixpkgs-lts,
  myFlakes, flatpaks,
  light-wallpaper, dark-wallpaper,
  snowflake,
  mullvad-browser-home-manager,
  ts-warp-nixpkgs, qutebrowser,
  ... }:

let
  system = pkgs.system;
  pkgs-backports = import nixpkgs-backports {
    inherit system;
    config.allowUnfree = true;
  };
  tmux = myFlakes.packages.${system}.tmux;
in {
  imports = [
    home-manager.nixosModules.home-manager
    ./base.nix
    ./roles/desktop/user-icon.nix
    ./roles/virtualization/libvirt.nix
  ];

  nixpkgs.overlays = [
    # Import nur as nixpkgs.overlays
    nur.overlay
  ];

  boot = {
    kernelParams = [ "quiet" "splash" ];
    plymouth.enable = true;
    consoleLogLevel = 0;
    initrd.verbose = false;
  };

  nix.settings = {
    sandbox = true;
    substituters = [
      #"https://hyprland.cachix.org"
    ];
    trusted-public-keys = [
      #"hyprland.cachix.org-1:a7pgxzMz7+chwVL3/pzj6jIBMioiJM7ypFP8PwtkuGc="
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
  services.xserver.displayManager.gdm = {
    enable = true;
  };
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

  # Enable hyprland
  #programs.hyprland = {
  #  enable = true;
  #  xwayland.enable = true;
  #};
  #services.displayManager.defaultSession = "hyprland";
  #security.pam.services.swaylock.text = "auth include login";
  #hardware.brillo.enable = true;

  # Enable kde connect
  programs.kdeconnect.enable = true;
  networking.firewall = {
    interfaces.tailscale0.allowedTCPPortRanges = [ { from = 1714; to = 1764; } { from = 3131; to = 3131;} ];
    interfaces.tailscale0.allowedUDPPortRanges = [  { from = 1714; to = 1764; } ];
  };

  # Enable Tailscale
  services.tailscale.enable = true;

  # Configure keymap in X11
  services.xserver.xkb = {
    layout = "us";
    variant = "";
  };

  # Enable CUPS to print documents.
  services.printing = {
    enable = true;
    drivers = [ pkgs-backports.hplipWithPlugin ];
  };
  services.avahi = {
    enable = true;
    nssmdns4 = true;
    openFirewall = true; # For wifi printers
  };
  # For scanning documents
  hardware.sane = {
    enable = true;
    extraBackends = [ pkgs-backports.hplipWithPlugin ];
  };
  users.extraGroups.lp.members = [ "heywoodlh" ];
  users.extraGroups.scanner.members = [ "heywoodlh" ];

  # Enable sound with pipewire.
  #sound.enable = true;
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

  # Allow x86 packages to be installed on aarch64
  nixpkgs.config.allowUnsupportedSystem = true;

  networking.firewall = {
    enable = true;
    checkReversePath = "loose";
  };

  fonts.packages = with pkgs; [
    (nerdfonts.override { fonts = [ "Hack" "DroidSansMono" "Iosevka" "JetBrainsMono" ]; })
  ];

  users.users.heywoodlh = {
    isNormalUser = true;
    description = "Spencer Heywood";
    extraGroups = [ "networkmanager" "wheel" "adbusers" ];
    shell = "${pkgs.bash}/bin/bash";
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
      inherit snowflake;
      inherit ts-warp-nixpkgs;
      inherit qutebrowser;
    };
    backupFileExtension = ".bak";
    users.heywoodlh = { ... }: {
      imports = [
        (mullvad-browser-home-manager + /modules/programs/mullvad-browser.nix)
        ../home/linux.nix
        ../home/desktop.nix # base desktop.nix
        ../home/linux/desktop.nix # linux-specific desktop.nix
        ../home/linux/gnome-desktop.nix
        flatpaks.homeManagerModules.default
        (import myFlakes.packages.${system}.gnome-dconf)
        #hyprland.homeManagerModules.default
        #../home/linux/hyprland.nix
      ];
      home.packages = [
        myFlakes.packages.${system}.git
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
      home.file.".config/fish/machine.fish" = {
        enable = true;
        text = ''
          # Always set 1password agent on NixOS desktops
          test -e ~/.1password/agent.sock && export SSH_AUTH_SOCK="$HOME/.1password/agent.sock"
        '';
      };
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
}
