# Config specific to Lenovo X13 Intel Gen 5
{ config, pkgs, lib, nixpkgs-pam-lid-fix, nixpkgs-stable, nixpkgs-fprintd-fix, nixos-hardware, spicetify, lanzaboote, ... }:

let
  system = pkgs.system;
  fprintd-fix-pkgs = import nixpkgs-fprintd-fix {
    inherit system;
    config.allowUnfree = true;
  };
  stable-pkgs = import nixpkgs-stable {
    inherit system;
    config.allowUnfree = true;
  };
in {
  disabledModules = [
    "security/pam.nix"
    "services/security/fprintd.nix"
  ];
  imports = [
    # Include the results of the hardware scan.
    ./hardware-configuration.nix
    ../../laptop.nix
    "${nixpkgs-pam-lid-fix}/nixos/modules/security/pam.nix"
    "${nixpkgs-pam-lid-fix}/nixos/modules/services/security/fprintd.nix"
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
  services.fprintd = {
    enable = true;
    lid = {
      authSkipLidClose = true; # do not use fingerprint on lid close
      path = "/proc/acpi/button/lid/LID/state";
    };
    tod = {
      enable = true;
      driver = fprintd-fix-pkgs.libfprint-2-tod1-goodix;
    };
    package = fprintd-fix-pkgs.fprintd-tod;
  };

  # Configuration for this machine
  home-manager.users.heywoodlh = {
    imports = [
      ../../../home/roles/discord.nix
    ];
    home.packages = with pkgs; [
      beeper
      gimp
      moonlight-qt
      spicetify.packages.${system}.nord-text
      webcord
      zoom-us
    ];
    heywoodlh.home.applications = [
      {
        name = "Rustdesk";
        command = ''
          bash -c "SHELL='/run/current-system/sw/bin/bash' ${stable-pkgs.rustdesk-flutter}/bin/rustdesk"
        '';
      }
    ];
  };
}
