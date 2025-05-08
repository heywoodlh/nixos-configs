# Config specific to p8 Micro PC
{ config, pkgs, nixpkgs-stable, lib, spicetify, lanzaboote, ... }:

{
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
      ../../console.nix
      ../../roles/remote-access/sshd.nix
      lanzaboote.nixosModules.lanzaboote
    ];

  # Bootloader
  boot.loader.systemd-boot.enable = false; # using lanzaboote
  boot.loader.efi.canTouchEfiVariables = true;
  hardware.enableRedistributableFirmware = true;
  boot.kernelPackages = pkgs.linuxKernel.packages.linux_xanmod_latest;

  networking.hostName = "nixos-micropc";

  boot = {
    kernelParams = [
      "i915.force_probe=46d1" # for display to work
      "fbcon=rotate:1" # rotate screen to correct orientation
    ];
    #extraModprobeConfig = "options g_ether use_eem=0 dev_addr=1a:55:89:a2:69:41 host_addr=1a:55:89:a2:69:42";
  };

  # ignore lid close
  services.logind.lidSwitchExternalPower = "ignore";

  networking.networkmanager.enable = true;

  # System packages
  environment.systemPackages = with pkgs; [
    lanzaboote
    sbctl
  ];

  # Hard limits for Nix
  nix.settings = {
    cores = 2;
    max-jobs = 2;
  };

  # Automate LUKS decryption with TPM2 with this command:
  # sudo systemd-cryptenroll --wipe-slot tpm2 --tpm2-device auto --tpm2-with-pin=no --tpm2-pcrs "7" /dev/sda1
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

  # Home-manager configs
  home-manager.users.heywoodlh = { ... }: {
    # FBTerm config
    home.file.".config/fbterm/fbtermrc" = {
      enable = true;
      text = ''
        screen-rotate=1
      '';
    };
  };

  # Disable sleep
  systemd.targets.sleep.enable = false;
  systemd.targets.suspend.enable = false;
  systemd.targets.hibernate.enable = false;
  systemd.targets.hybrid-sleep.enable = false;

}
