{ config, pkgs, spicetify, ... }:

let
  hostname = "nixos-macbook";
in {
  imports = [
    /etc/nixos/hardware-configuration.nix
    ../../roles/nixos/asahi.nix
    ../../desktop.nix
  ];

  # Bootloader
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = false;
  boot.initrd.luks.devices."cryptroot".device = "/dev/disk/by-uuid/40adb1af-7c06-47fc-99bb-80d61ff8cd8e";

  # Enable networking
  networking.networkmanager.enable = true;
  networking.hostName = "${hostname}"; # Define your hostname

  # Set your time zone.
  time.timeZone = "America/Denver";

  # Select internationalisation properties.
  i18n.defaultLocale = "en_US.utf8";

  # Configuration for this machine
  environment.systemPackages = with pkgs; [
    #rustdesk
    #signal-desktop
    webcord
  ];

  system.stateVersion = "23.11";
}
