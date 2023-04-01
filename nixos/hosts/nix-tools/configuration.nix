{ config, pkgs, ... }:

{
  imports =
  [ # Include the results of the hardware scan.
    ./hardware-configuration.nix
    ../../server.nix
    ../../../roles/tabby.nix
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

  # Set DNS
  networking.nameservers = [ "10.50.50.1" ];
  environment.etc = {
    "resolv.conf".text = "nameserver 10.50.50.1\n";
  };

  users.users.heywoodlh = {
    openssh.authorizedKeys.keys = [ 
      "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQC2NUJMRopUF8JvhLK4/l4zkgxZWNIZwxgfEWEoYsD9MnfCj9nflLxHM5zJ7pPx7DYoXaLguvdyCJlDNDlvd3vGW0RgfTyflZJzsQ6HxwsxO1dlyYJY6m0fekUXrFJBcU8uk0mMBO6rrMKMqz077qofCdzbf7vvdR5AsSy2pFcjiNSW0TwGCg3lrEUDX10bKFYkhHqSL/rF9ajZRs7EVVfFmilzGYKxRsvzpP6p72Gdxy50ebMcrUHAilwMzQnode8H+C25hQrkTJWhv9kmcNb//mJcar7atrvEGEBfUJ9/5A3FL6RNap1NPfLQ2w/mXtgfAqyHi1sq/f/+Kje1MazIu4y/U5oSGH3fc5iraN2wF0jIKO1LvDJQmbSrfjCq4FrBs24waPGtp+VcESfBIHYxyr740JMoi6BSjzvJR7gnyWkwWAEjoTBVL8szr2cbogna/g2pHmKDLagJlMOKQNTkPCUboKKj/Dy3wvim/m0D+aBXpkWnGiR7zEchiLV45Bc= sshwifty"
    ];
  };

  system.stateVersion = "22.11";
}
