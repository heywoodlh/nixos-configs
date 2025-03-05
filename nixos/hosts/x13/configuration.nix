# Config specific to Lenovo X13 Intel Gen 5
{ config, pkgs, lib, spicetify, nixos-hardware, lanzaboote, ... }:

{
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
      ../../desktop.nix
      nixos-hardware.nixosModules.lenovo-thinkpad-x13
      lanzaboote.nixosModules.lanzaboote
    ];

  networking.hostName = "nixos-thinkpad";
  # Bootloader -- using lanzaboote
  #boot.loader.systemd-boot.enable = true;
  # Enable networking
  networking.networkmanager.enable = true;
  # Set your time zone.
  time.timeZone = "America/Denver";
  # Select internationalisation properties.
  i18n.defaultLocale = "en_US.utf8";

  boot.kernelPackages = pkgs.linuxKernel.packages.linux_xanmod_latest; # use latest kernel for ARC GPU

  # System packages
  environment.systemPackages = with pkgs; [
    #clevis
    lanzaboote
    sbctl
  ];

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
    pkiBundle = "/var/lib/sbctl";
  };
  users.users.heywoodlh.extraGroups = [ "tss" ];

  # Hardware accelerated graphics
  hardware.graphics = {
    enable = true;
    extraPackages = with pkgs; [
      intel-media-driver
    ];
  };

  # Fingerprint
  services.fprintd.enable = true;
  services.fprintd.tod.enable = true;
  services.fprintd.tod.driver = pkgs.libfprint-2-tod1-goodix;

  # Configuration for this machine
  home-manager.users.heywoodlh = {
    imports = [
      ../../../home/roles/discord.nix
    ];
    home.packages = with pkgs; [
      beeper
      gimp
      moonlight-qt
      webcord
      zoom-us
    ];
    heywoodlh.home.applications = [
      {
        name = "Rustdesk";
        command = ''
          bash -c "SHELL='/run/current-system/sw/bin/bash' ${pkgs.rustdesk-flutter}/bin/rustdesk"
        '';
      }
    ];
  };
}
