# Config specific to Dell XPS 13
{ config, pkgs, lib, spicetify, nixos-x13s, ... }:

{
  imports =
    [ # Include the results of the hardware scan.
      nixos-x13s.nixosModules.default
      ./hardware-configuration.nix
      ../../desktop.nix
    ];

  nixos-x13s.enable = true;

  networking.hostName = "nixos-x13s";
  # Bootloader
  boot.loader.systemd-boot.enable = true;
  # Enable networking
  networking.networkmanager.enable = true;
  # Set your time zone.
  time.timeZone = "America/Denver";
  # Select internationalisation properties.
  i18n.defaultLocale = "en_US.utf8";

  # Fingerprint
  services.fprintd.enable = true;
  services.fprintd.tod.enable = true;
  services.fprintd.tod.driver = pkgs.libfprint-2-tod1-goodix;

  environment.systemPackages = with pkgs; [
    webcord
  ];
}
