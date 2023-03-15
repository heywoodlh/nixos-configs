# Config specific to Razer Blade 15

{ config, pkgs, lib, ... }:

{  
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
      ../../desktop.nix
      ../../../roles/gnome-boxes.nix
    ];
  
  boot.kernelParams = [ "button.lid_init_state=open" ];

  # Bootloader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.loader.efi.efiSysMountPoint = "/boot/efi";

  # Setup keyfile
  boot.initrd.secrets = {
    "/crypto_keyfile.bin" = null;
  };

  # Set hostname
  networking.hostName = "nix-razer"; 
  # Set DNS
  networking.nameservers = [ "10.50.50.1" ];
  environment.etc = {
    "resolv.conf".text = "nameserver 10.50.50.1\n";
  };


  # Set your time zone.
  time.timeZone = "America/Denver";

  # Select internationalisation properties.
  i18n.defaultLocale = "en_US.utf8";
 
  services.xserver = {
    videoDrivers = [ "nvidia" ];
  };
  hardware.opengl.enable = true;
  hardware.nvidia.package = config.boot.kernelPackages.nvidiaPackages.beta;

  hardware.nvidia = {
    powerManagement.enable = true;
    modesetting.enable = true;
    prime = {
      sync.enable = true;
      nvidiaBusId = "PCI:1:0:0";
      intelBusId = "PCI:0:2:0";
    };
  };

  # Create wireguard on demand service
  systemd.services = {
    wireguard = {
      enable = true;
      description = "Wireguard on Demand Service";
      unitConfig = {
        Type = "simple";
      };
      serviceConfig = {
        ExecStart = "/opt/scripts/wireguard.sh";
      };
      wantedBy = [ "multi-user.target" ];
    };
    wireguard-wired = {
      enable = true;
      description = "Wireguard on Demand Wired Service";
      unitConfig = {
        Type = "simple";
      };
      serviceConfig = {
        ExecStart = "/opt/scripts/wireguard-wired.sh";
      };
      wantedBy = [ "multi-user.target" ];
    };
  };
  
  # Set version of NixOS to target 
  system.stateVersion = "22.11";
}
