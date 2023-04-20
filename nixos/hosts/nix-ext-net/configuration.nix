{ config, pkgs, ... }:

{
  imports =
  [ # Include the results of the hardware scan.
    ./hardware-configuration.nix
    ../../server.nix
    ../../roles/pihole.nix
  ];

  # Bootloader.
  boot.loader.grub.enable = true;
  boot.loader.grub.version = 2;
  boot.loader.grub.device = "/dev/vda"; # or "nodev" for efi only
 
  # Enable networking
  networking.networkmanager.enable = true;
  networking.hostName = "nix-ext-net"; # Define your hostname

  # Set your time zone.
  time.timeZone = "America/Denver";
  
  # Select internationalisation properties.
  i18n.defaultLocale = "en_US.utf8";

  # Enable auto upgrade
  system.autoUpgrade = {
    enable = true;
    flake = "github:heywoodlh/nixos-configs#nix-ext-net";
  };

  system.stateVersion = "22.11";
}
