{ config, pkgs, home-manager, nur, ... }:

{
  imports = [
    home-manager.nixosModule
    ../roles/home-manager/linux/no-desktop.nix
    ./roles/sshd.nix
    ./roles/sshd-monitor.nix
    ./roles/squid-client.nix
    ./roles/tailscale.nix
  ];

  home-manager.useGlobalPkgs = true;

  # Import nur as nixpkgs.overlays
  nixpkgs.overlays = [ 
    nur.overlay 
  ];
  
  # Allow non-free applications to be installed
  nixpkgs.config.allowUnfree = true;

  # So that `nix search` works
  nix.extraOptions = '' 
    extra-experimental-features = nix-command flakes
  '';
  # Automatically optimize store for better storage
  nix.settings.auto-optimise-store = true;

  # Packages to install on entire system  
  environment.systemPackages = with pkgs; [
    autoPatchelfHook
    bind
    busybox
    croc
    file
    gcc
    git
    gnumake
    gnupg 
    gptfdisk
    htop
    jq 
    nix-index
    patchelf
    python310 
    python310Packages.pip
    unzip
    vim
    wireguard-tools
    zsh
  ];

  # Enable Docker 
  virtualisation = {
    docker.enable = true;
  };

  # Define use
  programs.zsh.enable = true;
  users.users.heywoodlh = {
    isNormalUser = true;
    uid = 1000;
    home = "/home/heywoodlh";
    description = "Spencer Heywood";
    extraGroups = [ "wheel" ];
    shell = pkgs.zsh;
  };

  # Set home-manager configs for username
  home-manager.users.heywoodlh = import ../roles/home-manager/linux.nix;

  # Allow heywoodlh to run sudo commands without password
  security.sudo.wheelNeedsPassword = false;

  # Disable wait-online service for Network Manager
  systemd.services.NetworkManager-wait-online.enable = false;

  nix.gc = {
    automatic = true;
    dates = "daily";
    options = "--delete-older-than 7d";
  };
}
