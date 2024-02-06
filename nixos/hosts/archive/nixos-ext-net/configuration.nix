{ config, pkgs, lib, ... }:

{
  imports =
  [ # Include the results of the hardware scan.
    /etc/nixos/hardware-configuration.nix
    ../../server.nix
    ../../roles/networking/pihole.nix
    ../../roles/networking/squid.nix
    ../../roles/protonmail-bridge.nix
    ../../roles/monitoring/iperf.nix
    ../../roles/http-proxy-pac.nix
    ../../roles/remote-access/rustdesk.nix
    ../../roles/remote-access/cloudflared.nix
    ../../roles/messaging/ntfy.nix
    ../../roles/monitoring/bash-uptime.nix
  ];

  # /dev/vdb1
  fileSystems."/nix" =
    { device = "/dev/disk/by-uuid/8d270e9f-16c7-4dbf-8954-8d93b4d548a6";
      fsType = "ext4";
    };

  # /dev/vdc1
  fileSystems."/opt" =
    { device = "/dev/disk/by-uuid/7be4354a-a167-423e-9297-f5daae458553";
      fsType = "ext4";
    };

  # /dev/vdd1
  fileSystems."/var" =
    { device = "/dev/disk/by-uuid/467cdd51-b939-43e3-b844-defec76812ce";
      fsType = "ext4";
    };

  # Bootloader.
  boot.loader.grub.enable = true;
  boot.loader.grub.version = 2;
  boot.loader.grub.device = "/dev/vda"; # or "nodev" for efi only

  # Enable networking
  networking.networkmanager.enable = true;
  networking.hostName = "nixos-ext-net"; # Define your hostname

  # Set your time zone.
  time.timeZone = "America/Denver";

  # Select internationalisation properties.
  i18n.defaultLocale = "en_US.utf8";

  # Enable mullvad wireguard
  networking.wg-quick.interfaces = {
    mullvad = {
      address = [ "10.66.216.224/32" ];
      privateKeyFile = "/root/wgkey";
      listenPort = 51820;

      peers = [
        {
          publicKey = "vkbSMnaddVm4YWkuuf8rOSc45XTfpVLJEom0FaJWq2g=";
          allowedIPs = [ "10.64.0.1/24" ];
          endpoint = "69.4.234.141:51820";
          persistentKeepalive = 25;
        }
      ];
    };
  };

  # Forward port 1080 to tailscale interface to mullvad
  networking = {
    firewall = {
      enable = true;
      allowedTCPPorts = [ 1080 ];
      extraCommands = "iptables -t nat -A POSTROUTING -d 10.64.0.1 -p tcp -m tcp --dport 1080 -j MASQUERADE";
    };
    nat = {
      enable = true;
      internalInterfaces = [ "mullvad" ];
      externalInterface = "tailscale0";
      forwardPorts = [
        {
          sourcePort = 1080;
          proto = "tcp";
          destination = "10.64.0.1:1080";
        }
      ];
    };
  };

  # Enable auto upgrade
  system.autoUpgrade = {
    enable = true;
    flake = "github:heywoodlh/nixos-configs#nix-ext-net";
  };

  # Disable squid client on this system
  # Prevents recursive dependencies
  # I.E. squid not able to come up due to squid not being up
  networking.proxy = {
    default = lib.mkForce null;
    httpProxy = lib.mkForce config.networking.proxy.default;
    httpsProxy = lib.mkForce config.networking.proxy.default;
    noProxy = lib.mkForce config.networking.proxy.default;
  };

  system.stateVersion = "22.11";
}
