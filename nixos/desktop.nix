{ config, pkgs, lib, home-manager, nur, vim-configs, hyprland, ... }:

let
  system = pkgs.system;
in {
  imports = [
    home-manager.nixosModules.home-manager
    ./roles/desktop/user-icon.nix
  ];

  home-manager.useGlobalPkgs = true;

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
  # Automatically optimize store for better storage
  nix.settings.auto-optimise-store = true;

  # Networking
  networking = {
    nftables.enable = true;
    networkmanager.enable = true;
  };

  # Enable the X11 windowing system.
  services.xserver.enable = true;

  # Enable nord-themed lightdm
  services.xserver.displayManager.lightdm = {
    enable = true;
    background = builtins.fetchurl {
      url = "https://raw.githubusercontent.com/NixOS/nixos-artwork/ac04f06feb980e048b4ab2a7ca32997984b8b5ae/wallpapers/nix-wallpaper-dracula.png";
      sha256 = "sha256:07ly21bhs6cgfl7pv4xlqzdqm44h22frwfhdqyd4gkn2jla1waab";
    };
    greeters.gtk = {
      enable = true;
      theme = {
        name = "Nordic-darker";
        package = pkgs.nordic;
      };
    };
  };

  # Enable hyprland
  programs.hyprland = {
    enable = true;
    xwayland.enable = true;
  };
  security.pam.services.swaylock.text = "auth include login";
  hardware.brillo.enable = true;

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

  ## Bluetooth
  hardware.bluetooth = {
    enable = true;
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
    shell = pkgs.zsh;
    # users.users.<name>.icon not a NixOS option
    # made possible with ./roles/desktop/user-icon.nix
    icon = builtins.fetchurl {
      url = "https://avatars.githubusercontent.com/u/18178614?v=4";
      sha256 = "sha256:02937kl4qmj29gms9r06kckq8fjpvl40bqi9vpxipwa4xy0wrymg";
    };
    homeMode = "755";
  };

  environment.homeBinInPath = true;
  programs.zsh.enable = true;
  environment.shells = [
    pkgs.bashInteractive
    pkgs.zsh
    "/run/current-system/sw/bin/zsh"
  ];

  # Bluetooth settings
  hardware.bluetooth.settings = {
    # Necessary for Airpods
    General = { ControllerMode = "dual"; } ;
  };

  # Desktop packages
  environment.systemPackages = [
    pkgs.busybox
    pkgs.usbutils
    vim-configs.defaultPackage.${system}
  ];

  # Disable wait-online service for Network Manager
  systemd.services.NetworkManager-wait-online.enable = false;

  # Home-manager configs
  home-manager.users.heywoodlh = { ... }: {
    imports = [
      ../roles/home-manager/linux.nix
      ../roles/home-manager/desktop.nix # base desktop.nix
      ../roles/home-manager/linux/desktop.nix # linux-specific desktop.nix
      hyprland.homeManagerModules.default
      ../roles/home-manager/linux/hyprland.nix
    ];
  };

  # Automatically garbage collect
  nix.gc = {
    automatic = true;
    dates = "daily";
    options = "--delete-older-than 7d";
  };
}
