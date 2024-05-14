{ config, pkgs, lib, ... }:

{
  imports =
  [ # Include the results of the hardware scan.
    ./hardware-configuration.nix
    ../../server.nix
    ../../roles/virtualization/libvirt.nix
    ../../roles/monitoring/syslog-ng/server.nix
    ../../roles/monitoring/syslog-ng/client.nix
    ../../roles/gaming/minecraft-bedrock.nix
    #../../roles/monitoring/graylog.nix
    ../../roles/containers/k3s.nix
    ../../roles/remote-access/guacamole.nix
    ../../roles/security/fleetdm.nix
    ../../roles/monitoring/osqueryd.nix
    ../../roles/nixos/cache.nix
    #../../roles/dev/vscode.nix # many things don't work with non-standard Nix paths
  ];

  # Bootloader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.loader.efi.efiSysMountPoint = "/boot/efi";

  # Enable networking
  networking.networkmanager.enable = true;
  networking.hostName = "nix-nvidia"; # Define your hostname

  # Set your time zone.
  time.timeZone = "America/Denver";

  # Select internationalisation properties.
  i18n.defaultLocale = "en_US.utf8";

    # Enable auto upgrade
  system.autoUpgrade = {
    enable = true;
    flake = "github:heywoodlh/nixos-configs#nix-nvidia";
  };

  # Enable Nvidia driver
  boot.kernelPackages = lib.mkForce pkgs.linuxKernel.packages.linux_xanmod_stable;
  nixpkgs.config.allowUnfree = true;
  # Make sure opengl is enabled
  hardware.opengl = {
    enable = true;
    driSupport = true;
    driSupport32Bit = true;
  };

  # Tell Xorg to use the nvidia driver (also valid for Wayland)
  services.xserver.videoDrivers = ["nvidia"];

  hardware.nvidia = {
    modesetting.enable = true;
    open = false;
    nvidiaSettings = true;
    package = pkgs.linuxKernel.packages.linux_xanmod_stable.nvidia_x11;
  };

  # This drive seems to have issues
  #fileSystems."/media/disk1" ={
  #  device = "/dev/disk/by-uuid/01cc4cb8-4646-471c-969d-a8729570c564";
  #  fsType = "btrfs";
  #  options = [ "rw" "uid=1000" "rw" "relatime" "x-systemd.mount-timeout=5min" ];
  #};

  # Prevent system from sleeping (for XRDP to work)
  systemd.targets.sleep.enable = false;
  systemd.targets.suspend.enable = false;
  systemd.targets.hibernate.enable = false;
  systemd.targets.hybrid-sleep.enable = false;

  # K8s cluster
  services.k3s = {
    role = "server";
    extraFlags = toString [
      "--tls-san=nix-nvidia"
      "--tls-san=100.108.77.60"
    ];
  };

  # Enable mullvad wireguard
  networking.wg-quick.interfaces = {
    mullvad = {
      address = [ "10.69.133.48/32" ];
      privateKeyFile = "/root/wgkey";
      listenPort = 51820;

      peers = [
        {
          publicKey = "ioipHdOYhc4nVsQKghmJy/vvnMI38VLLFNZXWgxxOx8=";
          allowedIPs = [ "10.64.0.1/24" ];
          endpoint = "69.4.234.139:51820";
          persistentKeepalive = 25;
        }
      ];
    };
  };

  # Forward port 1080 to tailscale interface to mullvad
  networking = {
    firewall = {
      enable = true;
      allowedUDPPorts = [
        9995
      ];
      allowedTCPPorts = [
        1080
        443
        3389
        5900
      ];
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

  hardware.bluetooth.enable = true;
  hardware.bluetooth.powerOnBoot = true;

  # Nvidia container settings
  virtualisation.docker = {
    enable = true;
    enableNvidia = true;
  };
  environment.systemPackages = with pkgs; [ docker runc ];

  system.stateVersion = "23.11";
}
