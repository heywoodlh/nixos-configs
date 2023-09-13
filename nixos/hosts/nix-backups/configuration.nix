{ config, pkgs, ... }:

{
  imports =
  [ # Include the results of the hardware scan.
    ./hardware-configuration.nix
    ../../server.nix
    ../../roles/rsnapshot.nix
    ../../roles/monitoring/scrutiny.nix
  ];

  # Bootloader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.loader.efi.efiSysMountPoint = "/boot/efi";

  # Enable networking
  networking.networkmanager.enable = true;
  networking.hostName = "nix-backups"; # Define your hostname

  # Enable wireguard
  networking.wg-quick.interfaces = {
    shadow = {
      address = [ "10.50.50.34/24" ];
      privateKeyFile = "/root/wgkey";
      listenPort = 51820;

      peers = [
        {
          publicKey = "3oM6JqkTEG34mDB6moDPRrhiRUtW3EqYGQXvb3/gzXc=";
          allowedIPs = [ "10.50.50.0/24" "10.51.51.0/24" ];
          endpoint = "209.213.47.169:51820";
          persistentKeepalive = 25;
        }
      ];
    };
  };

  # Set your time zone.
  time.timeZone = "America/Denver";

  # Select internationalisation properties.
  i18n.defaultLocale = "en_US.utf8";

  # Set DNS
  #networking.nameservers = [ "10.50.50.1" ];
  #environment.etc = {
  #  "resolv.conf".text = "nameserver 10.50.50.1\n";
  #};

  # Ignore lid close
  services.logind.lidSwitch = "ignore";
  services.logind.lidSwitchExternalPower = "ignore";
  services.logind.lidSwitchDocked = "ignore";

  # Install btrfs-progs
  environment.systemPackages = with pkgs; [
    btrfs-progs
  ];

  # Mount backup drive
  fileSystems."/media/backups" = {
    device = "/dev/disk/by-uuid/fd16f657-ba9c-4829-9f71-3869ee18f240";
    fsType = "btrfs";
    options = [ "defaults" "nofail" ];
  };

  # Enable auto upgrade
  system.autoUpgrade = {
    enable = true;
    flake = "github:heywoodlh/nixos-configs#nix-backups";
  };

  virtualisation.oci-containers.containers.scrutiny.extraOptions = [
    "--device=/dev/sda"
    "--device=/dev/sdb"
  ];



  system.stateVersion = "22.11";
}
