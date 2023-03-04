{ config, pkgs, ... }:

let
  kubeMasterIP = "10.0.50.41";
  kubeMasterHostname = "nix-kube-1.kube";
  kubeMasterAPIServerPort = 6443;
in {
  imports =
  [ # Include the results of the hardware scan.
    ./hardware-configuration.nix
    ../../server.nix
  ];

  # Bootloader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.loader.efi.efiSysMountPoint = "/boot/efi";
  
  # Enable networking
  networking.networkmanager.enable = true;
  networking.hostName = "nix-kube-1"; # Define your hostname

  # Enable wireguard
  networking.wg-quick.interfaces = {
    shadow = {
      address = [ "10.50.50.41/24" ];
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

  # Kubernetes master
  # resolve master hostname
  networking.extraHosts = "${kubeMasterIP} ${kubeMasterHostname}";

  # packages for administration tasks
  environment.systemPackages = with pkgs; [
    kompose
    kubectl
    kubernetes
  ];

  # allow kubernetes port
  networking.firewall.allowedTCPPorts = [ kubeMasterAPIServerPort ];	

  services.kubernetes = {
    roles = ["master" "node"];
    masterAddress = kubeMasterHostname;
    apiserverAddress = "https://${kubeMasterHostname}:${toString kubeMasterAPIServerPort}";
    easyCerts = true;
    apiserver = {
      securePort = kubeMasterAPIServerPort;
      advertiseAddress = kubeMasterIP;
    };

    # use coredns
    addons.dns.enable = true;

    # needed if you use swap
    #kubelet.extraOpts = "--fail-swap-on=false";
  };
  
  system.stateVersion = "22.11";
}
