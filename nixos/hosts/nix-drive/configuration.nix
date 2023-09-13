{ config, pkgs, ... }:

{
  imports =
  [ # Include the results of the hardware scan.
    ./hardware-configuration.nix
    ../../server.nix
    ../../roles/storage/nextcloud.nix
    ../../roles/monitoring/scrutiny.nix
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
  fileSystems."/media/storage" = {
    device = "/dev/disk/by-uuid/ce3c27ed-2e55-40a9-9737-154e71a637b4";
    fsType = "ext4";
  };

  virtualisation.oci-containers.containers.scrutiny.extraOptions = [
    "--device=/dev/vda"
    "--device=/dev/sda"
  ];

  system.stateVersion = "23.05";
}
