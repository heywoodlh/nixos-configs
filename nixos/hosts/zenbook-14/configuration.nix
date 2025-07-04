# Config specific to ASUS Zenbook 14
{ config, pkgs, nixpkgs-stable, lib, spicetify, lanzaboote, ... }:

let
  system = pkgs.system;
  stable-pkgs = import nixpkgs-stable {
    inherit system;
    config.allowUnfree = true;
  };
in {
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
      ../../laptop.nix
      #../../roles/desktop/hyprland.nix
      lanzaboote.nixosModules.lanzaboote
    ];

  # Bootloader
  boot.loader.systemd-boot.enable = false; # using lanzaboote
  boot.loader.efi.canTouchEfiVariables = true;
  hardware.enableRedistributableFirmware = true; # enable firmware for ARC GPU
  boot.kernelPackages = pkgs.linuxKernel.packages.linux_xanmod_latest; # use latest kernel for ARC GPU

  networking.hostName = "nixos-zenbook"; # Define your hostname.

  # Enable networking
  networking.networkmanager.enable = true;

  # Set your time zone
  time.timeZone = "America/Denver";

  # Configuration for this machine
  home-manager.users.heywoodlh = {
    imports = [
      ../../../home/roles/discord.nix
    ];
    home.packages = with pkgs; [
      stable-pkgs.beeper
      gimp
      moonlight-qt
      spicetify.packages.x86_64-linux.nord
      stable-pkgs.legcord
      stable-pkgs.rustdesk
      zoom-us
    ];
  };

  # System packages
  environment.systemPackages = with pkgs; [
    #clevis
    lanzaboote
    sbctl
  ];

  # Hard limits for Nix
  nix.settings = {
    cores = 2;
    max-jobs = 2;
  };

  # Firmware updates
  services.fwupd.enable = true;

  # Automate LUKS decryption with TPM2 with this command:
  # sudo systemd-cryptenroll --wipe-slot tpm2 --tpm2-device auto --tpm2-with-pin=no --tpm2-pcrs "7" /dev/nvme0n1p2
  boot.initrd.systemd.enable = true;
  boot.initrd.systemd.tpm2.enable = true;
  security.tpm2.enable = true;
  security.tpm2.pkcs11.enable = true;
  security.tpm2.tctiEnvironment.enable = true;
  # Secure boot
  boot.lanzaboote = {
    enable = true;
    pkiBundle = "/etc/secureboot";
  };
  users.users.heywoodlh.extraGroups = [ "tss" ];

  # Hardware accelerated graphics
  hardware.graphics = {
    enable = true;
    extraPackages = with pkgs; [
      intel-media-driver
    ];
  };

  # Fingerprint reader support
  services.fprintd.enable = true;
  services.fprintd.tod.enable = true;
  services.fprintd.tod.driver = pkgs.libfprint-2-tod1-goodix;

}
