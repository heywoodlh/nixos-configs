{ config, pkgs, ... }:

{
  imports =
  [ # Include the results of the hardware scan.
    ./hardware-configuration.nix
    ../../server.nix
  ];

  # Bootloader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  # Enable networking
  networking.networkmanager.enable = true;
  networking.hostName = "nix-drive"; # Define your hostname

  # Set your time zone.
  time.timeZone = "America/Denver";

  # Select internationalisation properties.
  i18n.defaultLocale = "en_US.utf8";

  # Enable auto upgrade
  system.autoUpgrade = {
    enable = true;
    flake = "github:heywoodlh/nixos-configs#nix-drive";
  };

  # Media mounts
  #fileSystems."/media/disk1" = {
  #  device = "/dev/disk/by-uuid/5f1975e9-ffde-4dbf-bd14-657bfb26287a";
  #  fsType = "btrfs";
  #};

  system.stateVersion = "23.05";
}
