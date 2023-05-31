{ config, pkgs, ... }:

{
  imports =
  [ # Include the results of the hardware scan.
    ./hardware-configuration.nix
    ../../server.nix
    ../../../roles/sshd.nix
    ../../../roles/sshd-monitor.nix
  ];

  # Enable Grub
  boot.loader.grub.enable = true;
  boot.loader.grub.device = "/dev/sda";
  boot.loader.grub.useOSProber = true;

  # Enable networking
  networking.networkmanager.enable = true;
  networking.hostName = "nix-vostro"; # Define your hostname

  # Allow Syncthing over Wireguard
  networking.firewall.interfaces.shadow = {
    allowedTCPPorts = [ 8384 ];
  };

  # Allow syncthing on all interfaces
  services.syncthing.guiAddress = "0.0.0.0:8384";
  # Enable wireguard
  networking.wg-quick.interfaces = {
    shadow = {
      address = [ "10.50.50.40/24" ];
      privateKeyFile = "/root/wgkey";
      listenPort = 51820;

      peers = [
        {
          publicKey = "3oM6JqkTEG34mDB6moDPRrhiRUtW3EqYGQXvb3/gzXc=";
          allowedIPs = [ "10.50.50.0/24" "10.51.51.0/24" ];
          endpoint = "10.0.50.50:51820";
          persistentKeepalive = 25;
        }
      ];
    };
  };

  # Set your time zone.
  time.timeZone = "America/Denver";

  # Select internationalisation properties.
  i18n.defaultLocale = "en_US.utf8";

  # Configure keymap in X11
  services.xserver = {
    layout = "us";
    xkbVariant = "";
  };

  # Set DNS
  networking.nameservers = [ "10.50.50.1" ];
  environment.etc = {
    "resolv.conf".text = "nameserver 10.50.50.1\n";
  };

  system.stateVersion = "22.11";
}
