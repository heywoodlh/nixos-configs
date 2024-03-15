{ config, pkgs, ... }:

{
  imports =
  [ # Include the results of the hardware scan.
    ./hardware-configuration.nix
    ../../server.nix
    #../../roles/media/plex.nix
    #../../roles/media/deluge.nix
    #../../roles/media/freshrss.nix
    #../../roles/oss-frontend.nix
    #../../roles/containers/syncthing.nix
    #../../roles/feeds/rsshub.nix
    #../../roles/feeds/miniflux.nix
    #../../roles/monitoring/scrutiny.nix
    #../../roles/storage/nfs-media.nix
  ];

  # Bootloader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.loader.efi.efiSysMountPoint = "/boot/efi";

  # Enable networking
  networking.networkmanager.enable = true;
  networking.hostName = "nix-media"; # Define your hostname

  # Set your time zone.
  time.timeZone = "America/Denver";

  # Select internationalisation properties.
  i18n.defaultLocale = "en_US.utf8";

  # Enable auto upgrade
  system.autoUpgrade = {
    enable = true;
    flake = "github:heywoodlh/nixos-configs#nix-media";
  };

  # Media mounts
  #fileSystems."/media/disk1" = {
  #  device = "/dev/disk/by-uuid/5f1975e9-ffde-4dbf-bd14-657bfb26287a";
  #  fsType = "btrfs";
  #};

  #fileSystems."/media/disk2" = {
  #  device = "/dev/disk/by-uuid/7d1d10dd-392d-47ce-b178-bffd2295637e";
  #  fsType = "btrfs";
  #};

  # Host-specific bitlbee config
  services.bitlbee = {
    hostName = "nix-media.tailscale";
    interface = "100.67.2.30";
  };

  # Docker config
  virtualisation.docker.extraOptions = ''
    --data-root /media/disk1/docker
  '';

  #virtualisation.oci-containers.containers.scrutiny.extraOptions = [
  #  "--device=/dev/vda"
  #  "--device=/dev/vdc"
  #  "--device=/dev/vdb"
  #];

  system.stateVersion = "22.11";
}
