{ config, pkgs, ... }:

{
  imports =
  [ # Include the results of the hardware scan.
    ./hardware-configuration.nix
    ../../server.nix
    ../../roles/pomerium.nix
  ];

  # Bootloader.
  boot.loader.grub.enable = true;
  boot.loader.grub.version = 2;
  boot.loader.grub.device = "/dev/vda"; # or "nodev" for efi only

  # Enable networking
  networking.networkmanager.enable = true;
  networking.hostName = "nix-pomerium"; # Define your hostname

  # Enable wireguard
  networking.wg-quick.interfaces = {
    shadow = {
      address = [ "10.50.50.35/24" ];
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

  # Set crons
  # Enable cron service
  services.cron = {
    enable = true;
    systemCronJobs = [
      "0 0 * * Sun      root    /opt/certbot/certbot.sh &> /dev/null"
      "0 1 * * Sun      root    /opt/heywoodlh.tech-certbot/certbot.sh &> /dev/null"
    ];
  };

  # Enable auto upgrade
  system.autoUpgrade = {
    enable = true;
    flake = "github:heywoodlh/nixos-configs#nix-pomerium";
  };

  system.stateVersion = "22.11";
}
