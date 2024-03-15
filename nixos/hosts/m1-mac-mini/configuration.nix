{ config, pkgs, ... }:

let
  hostname = "nixos-mac-mini";
in {
  imports =
  [
    /etc/nixos/hardware-configuration.nix
    ../../desktop.nix
    ../../roles/nixos/asahi.nix
  ];

  # Bootloader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  # Enable networking
  networking.networkmanager.enable = true;
  networking.hostName = "${hostname}"; # Define your hostname

  # Set your time zone.
  time.timeZone = "America/Denver";

  # Select internationalisation properties.
  i18n.defaultLocale = "en_US.utf8";

  # Enable auto upgrade
  system.autoUpgrade = {
    enable = true;
    flake = "github:heywoodlh/nixos-configs#${hostname}";
  };

  system.stateVersion = "24.05";
}
