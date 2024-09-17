# Config specific to Dell XPS 13
{ config, pkgs, nixpkgs-stable, nixpkgs-pam-lid-fix, lib, spicetify, ... }:

let
  system = pkgs.system;
  stable-pkgs = import nixpkgs-stable {
    inherit system;
    config.allowUnfree = true;
  };
in {
  disabledModules = [
    "security/pam.nix"
    "services/security/fprintd.nix"
  ];
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
      ../../laptop.nix
      "${nixpkgs-pam-lid-fix}/nixos/modules/security/pam.nix"
      "${nixpkgs-pam-lid-fix}/nixos/modules/services/security/fprintd.nix"
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
      ../../../home/roles/discord.nix
    ];
    home.packages = with pkgs; [
      beeper
      rustdesk-flutter
      signal-desktop
      spicetify.packages.x86_64-linux.nord-text
      zoom-us
    ];
  };

  # Fingerprint
  services.fprintd = {
    enable = true;
    authSkipLidClose = true; # do not use fingerprint on lid close
    package = stable-pkgs.fprintd-tod;
    tod.enable = true;
    tod.driver = lib.mkForce stable-pkgs.libfprint-2-tod1-goodix;
  };

  # Hard limits for Nix
  nix.settings = {
    cores = 2;
    max-jobs = 2;
  };

  services.fwupd.enable = true;

  # Set version of NixOS to target
  system.stateVersion = "24.05";
}
