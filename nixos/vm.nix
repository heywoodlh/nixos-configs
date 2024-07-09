{ config, pkgs, lib, ... }:

{
  imports = [
    /etc/nixos/hardware-configuration.nix
    ./desktop.nix
    ./roles/remote-access/sshd.nix
    ./roles/dev/gnome-guest.nix
  ];

  # Bootloader
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = false;

  # Enable networking
  networking.networkmanager.enable = true;

  # Set your time zone.
  time.timeZone = "America/Denver";

  # Disable sound
  sound.enable = lib.mkForce false;
  services.pipewire = {
    enable = lib.mkForce false;
    alsa.enable = lib.mkForce false;
    alsa.support32Bit = lib.mkForce false;
    pulse.enable = lib.mkForce false;
  };

  # Disable bluetooth
  hardware.bluetooth.enable = lib.mkForce false;

  # Select internationalisation properties.
  i18n.defaultLocale = "en_US.utf8";
  system.stateVersion = "24.05";
}
