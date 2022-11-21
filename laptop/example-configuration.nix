# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, ... }:

{
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
      ./desktop.nix
      ./custom.nix
      <home-manager/nixos> 
    ];

  # Bootloader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.loader.efi.efiSysMountPoint = "/boot/efi";

  # Setup keyfile
  boot.initrd.secrets = {
    "/crypto_keyfile.bin" = null;
  };

  # Enable swap on luks
  boot.initrd.luks.devices."REPLACEME".device = "/dev/disk/by-uuid/";
  boot.initrd.luks.devices."REPLACEME".keyFile = "/crypto_keyfile.bin";

  networking.hostName = "REPLACEME"; # Define your hostname.

  # Set your time zone.
  time.timeZone = "America/Denver";

  # Select internationalisation properties.
  i18n.defaultLocale = "en_US.utf8";
 
  # Set version of NixOS to target 
  system.stateVersion = "22.05";
}
