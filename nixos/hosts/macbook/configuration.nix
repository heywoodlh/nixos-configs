{ config, pkgs, spicetify, ... }:

let
  hostname = "nixos-macbook";
in {
  imports =
  [
    /etc/nixos/hardware-configuration.nix
    /etc/nixos/apple-silicon-support
    ../../desktop.nix
  ];

  # Bootloader
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = false;

  # Enable networking
  networking.networkmanager.enable = true;
  networking.hostName = "${hostname}"; # Define your hostname

  # Set your time zone.
  time.timeZone = "America/Denver";

  # Select internationalisation properties.
  i18n.defaultLocale = "en_US.utf8";

  # Configuration for this machine
  home-manager.users.heywoodlh = {
    home.packages = with pkgs; [
      rustdesk
      signal-desktop
      spicetify.packages.x86_64-linux.nord
      webcord
      zoom-us
    ];
  };

  # Emulate x86_64 linux
  boot.binfmt.emulatedSystems = [ "x86_64-linux" ];

  system.stateVersion = "23.11";
}
