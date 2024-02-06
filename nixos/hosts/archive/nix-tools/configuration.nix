{ config, pkgs, ... }:

{
  imports =
  [ # Include the results of the hardware scan.
    ./hardware-configuration.nix
    ../../server.nix
    ../../roles/ansible-server.nix
    ../../roles/containers/k3s.nix
  ];

  # Bootloader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.loader.efi.efiSysMountPoint = "/boot/efi";

  # Enable networking
  networking.networkmanager.enable = true;
  networking.hostName = "nix-tools"; # Define your hostname

  # Enable wireguard
  networking.wg-quick.interfaces = {
    shadow = {
      address = [ "10.50.50.31/24" ];
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

  environment.systemPackages = with pkgs; [
    docker-compose
  ];

  # Enable auto upgrade
  system.autoUpgrade = {
    enable = true;
    flake = "github:heywoodlh/nixos-configs#nix-tools";
  };

  services.k3s.extraFlags = "--tls-san=nix-tools.tailscale";

  system.stateVersion = "22.11";
}
