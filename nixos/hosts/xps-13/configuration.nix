# Config specific to Dell XPS 13
{ config, pkgs, nixpkgs-stable, nixpkgs-pam-lid-fix, lib, spicetify, lanzaboote, ... }:

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
      lanzaboote.nixosModules.lanzaboote
    ];

  # Bootloader
  boot.loader.systemd-boot.enable = false; # using lanzaboote
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
      signal-desktop
      spicetify.packages.x86_64-linux.nord-text
      zoom-us
    ];
    heywoodlh.home.applications = [
      {
        name = "Rustdesk";
        command = ''
          bash -c "SHELL='/run/current-system/sw/bin/bash' /nix/store/n1imnqnc23yk5rvvcvmzp3r95zl0hb5i-rustdesk-1.3.0/bin/rustdesk"
        '';
      }
    ];
  };

  # System packages
  environment.systemPackages = with pkgs; [
    #clevis
    lanzaboote
    sbctl
  ];

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

  # Firmware updates
  services.fwupd.enable = true;

  # Automate LUKS decryption with TPM2 with this command:
  # sudo systemd-cryptenroll --wipe-slot tpm2 --tpm2-device auto --tpm2-with-pin=no --tpm2-pcrs "7" /dev/nvme0n1p2
  boot.initrd.systemd.enable = true;
  boot.initrd.systemd.enableTpm2 = true;
  security.tpm2.enable = true;
  security.tpm2.pkcs11.enable = true;
  security.tpm2.tctiEnvironment.enable = true;
  # Secure boot
  boot.lanzaboote = {
    enable = true;
    pkiBundle = "/etc/secureboot";
  };
  users.users.heywoodlh.extraGroups = [ "tss" ];

  # Clevis
  # Reference commands:
  # disk=/dev/nvme0n1p2
  # echo -n Enter LUKS password:
  # read -s LUKSKEY
  # echo ""
  # sudo mkdir -p /opt
  # echo -n "$LUKSKEY" | sudo nix run nixpkgs#clevis -- encrypt tpm2 '{}' | sudo tee /opt/nvme0n1p2.jwe
  #boot.initrd.clevis = {
  #  enable = true;
  #  devices."luks-1f9aebb9-ab34-4cac-85e9-7bad7cacd502".secretFile = "/opt/nvme0n1p2.jwe";
  #};

  # Set version of NixOS to target
  system.stateVersion = "24.05";
}
