{ config, pkgs, ... }:

{
  imports =
  [ # Include the results of the hardware scan.
    ./hardware-configuration.nix
    ../../server.nix
    ../../roles/libvirt.nix
    ../../roles/serge.nix
    ../../roles/dev/coder.nix
    ../../roles/syslog-ng/server.nix
    ../../roles/gaming/minecraft-bedrock.nix
    ../../roles/containers/k3s.nix
    ../../roles/containers/registry.nix
  ];

  # Bootloader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.loader.efi.efiSysMountPoint = "/boot/efi";

  # Enable networking
  networking.networkmanager.enable = true;
  networking.hostName = "nix-nvidia"; # Define your hostname

  # Set your time zone.
  time.timeZone = "America/Denver";

  # Select internationalisation properties.
  i18n.defaultLocale = "en_US.utf8";

    # Enable auto upgrade
  system.autoUpgrade = {
    enable = true;
    flake = "github:heywoodlh/nixos-configs#nix-nvidia";
  };

  # Enable Nvidia driver
  nixpkgs.config.allowUnfree = true;
  services.xserver.videoDrivers = [ "nvidia" ];
  hardware.opengl.enable = true;

  #environment.systemPackages = with pkgs; [
  #  ntfs3g
  #];

  # This drive seems to have issues
  #fileSystems."/media/disk1" ={
  #  device = "/dev/disk/by-uuid/01cc4cb8-4646-471c-969d-a8729570c564";
  #  fsType = "btrfs";
  #  options = [ "rw" "uid=1000" "rw" "relatime" "x-systemd.mount-timeout=5min" ];
  #};

  # Prevent system from sleeping (for XRDP to work)
  systemd.targets.sleep.enable = false;
  systemd.targets.suspend.enable = false;
  systemd.targets.hibernate.enable = false;
  systemd.targets.hybrid-sleep.enable = false;

  # K8s cluster for coder
  services.k3s.extraFlags = "--tls-san=nix-nvidia.tailscale";

  # Exposed ports
  networking.firewall.allowedTCPPorts = [
    443
  ];

  system.stateVersion = "22.11";
}
