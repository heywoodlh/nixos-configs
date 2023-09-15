# Config specific to Dell XPS 13

{ config, pkgs, lib, spicetify, nixpkgs-unstable, ... }:

let
  system = pkgs.system;
  unstable = nixpkgs-unstable.legacyPackages.${system};
in {
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
      ../../desktop.nix
    ];

  # Bootloader
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  # Setup keyfile
  boot.initrd.secrets = {
    "/crypto_keyfile.bin" = null;
  };

  networking.hostName = "nixos-xps"; # Define your hostname.

  # Enable networking
  networking.networkmanager.enable = true;

  # Set your time zone
  time.timeZone = "America/Denver";

  # Select internationalisation properties.
  i18n.defaultLocale = "en_US.utf8";

  # Configuration for this machine
  home-manager.users.heywoodlh = {
   home.packages = with pkgs; [
      signal-desktop
      spicetify.packages.x86_64-linux.nord
      webcord
      zoom-us
    ];
  };

  # Smart card
  services.pcscd.enable = true;
  environment.systemPackages = with pkgs; [
    yubikey-manager-qt
  ];
  services.udev.packages = with pkgs; [
    yubikey-manager-qt
  ];

  # Fingerprint
  services.fprintd.enable = true;
  services.fprintd.tod.enable = true;
  services.fprintd.tod.driver = pkgs.libfprint-2-tod1-goodix;

  # Disable suspend when docked
  services.logind.extraConfig = ''
    HandleLidSwitchDocked=ignore
  '';

  # Set version of NixOS to target
  system.stateVersion = "23.05";
}
