{ config, pkgs, ... }:

let
  hostname = "nixos-arm64-vm";
in {
  imports =
  [ # Include the results of the hardware scan.
    /etc/nixos/hardware-configuration.nix
    ../../desktop.nix
  ];

  # Bootloader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  # Enable networking
  networking.networkmanager.enable = true;
  networking.hostName = "${hostname}"; # Define your hostname

  # Set your time zone.
  time.timeZone = "America/Denver";

  # Use Rosetta2 in UTM
  virtualisation.rosetta.enable = true;

  # Enable auto upgrade
  system.autoUpgrade = {
    enable = true;
    flake = "github:heywoodlh/nixos-configs#${hostname}";
  };
}
