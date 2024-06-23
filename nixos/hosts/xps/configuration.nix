# Config specific to Dell XPS 13
{ config, pkgs, lib, spicetify, mullvad-browser-home-manager, ... }:

{
  imports =
    [ # Include the results of the hardware scan.
      /etc/nixos/hardware-configuration.nix
      ../../desktop.nix
    ];

  # Bootloader
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  # Setup keyfile
  #boot.initrd.secrets = {
  #  "/crypto_keyfile.bin" = null;
  #};

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
      (mullvad-browser-home-manager + /modules/programs/mullvad-browser.nix)
    ];
    home.packages = with pkgs; [
      signal-desktop
      spicetify.packages.x86_64-linux.nord-text
      webcord
      zoom-us
    ];
    programs.mullvad-browser = {
      profiles.home-manager = {
        search.default = lib.mkForce "Mullvad Leta";
      };
    };
  };

  # Fingerprint
  services.fprintd.enable = true;
  services.fprintd.tod.enable = true;
  services.fprintd.tod.driver = lib.mkForce pkgs.libfprint-2-tod1-goodix;

  # Set version of NixOS to target
  system.stateVersion = "23.11";
}
