{ config, pkgs, ... }:

{
  imports =
  [ # Include the results of the hardware scan.
    ./hardware-configuration.nix
    ../../server.nix
    ../../roles/pihole.nix
    ../../roles/squid.nix
    ../../roles/protonmail-bridge.nix
    ../../roles/gotify.nix
    ../../roles/gotify-convert.nix
  ];

  # Bootloader.
  boot.loader.grub.enable = true;
  boot.loader.grub.version = 2;
  boot.loader.grub.device = "/dev/vda"; # or "nodev" for efi only
 
  # Enable networking
  networking.networkmanager.enable = true;
  networking.hostName = "nix-ext-net"; # Define your hostname

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
  networking.firewall = {
    allowedTCPPorts = [
      1080
    ];
    extraCommands = ''
      iptables -A FORWARD -i tailscale0 -o mullvad -p tcp --syn --dport 1080 -m conntrack --ctstate NEW -j ACCEPT -w
      iptables -A FORWARD -i tailscale0 -o mullvad -m conntrack --ctstate ESTABLISHED,RELATED -j ACCEPT -w
      iptables -A FORWARD -i mullvad -o tailscale0 -m conntrack --ctstate ESTABLISHED,RELATED -j ACCEPT -w
      iptables -t nat -A PREROUTING -i tailscale0 -p tcp --dport 1080 -j DNAT --to-destination 10.64.0.1 -w
      iptables -t nat -A POSTROUTING -o mullvad -p tcp --dport 1080 -d 10.64.0.1 -j SNAT --to-source 100.113.9.57 -w
    '';
    extraStopCommands = ''
      iptables -D FORWARD -i tailscale0 -o mullvad -p tcp --syn --dport 1080 -m conntrack --ctstate NEW -j ACCEPT -w
      iptables -D FORWARD -i tailscale0 -o mullvad -m conntrack --ctstate ESTABLISHED,RELATED -j ACCEPT -w
      iptables -D FORWARD -i mullvad -o tailscale0 -m conntrack --ctstate ESTABLISHED,RELATED -j ACCEPT -w
      iptables -t nat -D PREROUTING -i tailscale0 -p tcp --dport 1080 -j DNAT --to-destination 10.64.0.1 -w
      iptables -t nat -D POSTROUTING -o mullvad -p tcp --dport 1080 -d 10.64.0.1 -j SNAT --to-source 100.113.9.57 -w
    '';
  };


  # Enable auto upgrade
  system.autoUpgrade = {
    enable = true;
    flake = "github:heywoodlh/nixos-configs#nix-ext-net";
  };

  system.stateVersion = "22.11";
}
