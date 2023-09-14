{ config, pkgs, ... }:

{
  imports =
  [ # Include the results of the hardware scan.
    ./hardware-configuration.nix
    ../../server.nix
    ../../roles/plex.nix
    ../../roles/deluge.nix
    ../../roles/freshrss.nix
    ../../roles/oss-frontend.nix
    ../../roles/containers/syncthing.nix
    ../../roles/feeds/rsshub.nix
    ../../roles/feeds/miniflux.nix
    ../../roles/messaging/bitlbee.nix
    ../../roles/messaging/thelounge.nix
    ../../roles/messaging/znc.nix
    ../../roles/monitoring/scrutiny.nix
  ];

  # Bootloader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.loader.efi.efiSysMountPoint = "/boot/efi";

  # Enable networking
  networking.networkmanager.enable = true;
  networking.hostName = "nix-media"; # Define your hostname

  # Enable wireguard
  networking.wg-quick.interfaces = {
    shadow = {
      address = [ "10.50.50.42/24" ];
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
  #networking.nameservers = [ "10.50.50.1" ];
  #environment.etc = {
  #  "resolv.conf".text = "nameserver 10.50.50.1\n";
  #};

  # Enable auto upgrade
  system.autoUpgrade = {
    enable = true;
    flake = "github:heywoodlh/nixos-configs#nix-media";
  };

  # Media mounts
  fileSystems."/media/disk1" = {
    device = "/dev/disk/by-uuid/5f1975e9-ffde-4dbf-bd14-657bfb26287a";
    fsType = "btrfs";
  };

  fileSystems."/media/disk2" = {
    device = "/dev/disk/by-uuid/7d1d10dd-392d-47ce-b178-bffd2295637e";
    fsType = "btrfs";
  };

  # Host-specific bitlbee config
  services.bitlbee = {
    hostName = "nix-media.tailscale";
    interface = "100.67.2.30";
  };

  # Docker config
  virtualisation.docker.extraOptions = ''
    --data-root /media/disk1/docker
  '';

  virtualisation.oci-containers.containers.scrutiny.extraOptions = [
    "--device=/dev/vda"
    "--device=/dev/vdc"
    "--device=/dev/vdb"
  ];

  system.stateVersion = "22.11";
}
