# Config specific to Dell XPS 13
{ config, pkgs, lib, spicetify, ... }:

{
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
      ../../laptop.nix
    ];

  # Bootloader
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  networking.hostName = "nixos-xps"; # Define your hostname.

  # Enable networking
  networking.networkmanager.enable = true;

  # Set your time zone
  time.timeZone = "America/Denver";

  # Select internationalisation properties.
  i18n.defaultLocale = "en_US.utf8";

  # Configuration for this machine
  home-manager.users.heywoodlh = {
    imports = [
      ../../home/roles/discord.nix
    ];
    home.packages = with pkgs; [
      signal-desktop
      spicetify.packages.x86_64-linux.nord-text
      zoom-us
    ];
  };

  # Fingerprint
  services.fprintd.enable = true;
  services.fprintd.tod.enable = true;
  services.fprintd.tod.driver = lib.mkForce pkgs.libfprint-2-tod1-goodix;

  # Hard limits for Nix
  nix.settings = {
    cores = 2;
    max-jobs = 2;
  };

  services.fwupd.enable = true;

  # Set version of NixOS to target
  system.stateVersion = "24.05";
}
