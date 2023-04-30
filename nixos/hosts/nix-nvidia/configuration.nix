{ config, pkgs, ... }:

{
  imports =
  [ # Include the results of the hardware scan.
    ./hardware-configuration.nix
    ../../server.nix
    ../../roles/libvirt.nix
    ../../roles/serge.nix
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
  nixpkgs.config.allowUnfree = true;
  services.xserver.videoDrivers = [ "nvidia" ];
  hardware.opengl.enable = true;
  hardware.opengl.driSupport32Bit = true;
  virtualisation.docker.enableNvidia = true;

  environment.systemPackages = with pkgs; [
    ntfs3g
  ];

  # Support NTFS
  boot.supportedFilesystems = [ "ntfs" ];
  fileSystems."/opt/sunshine/steam" =
    { device = "/dev/disk/by-uuid/3E7EF2A470BF8D03";
      fsType = "ntfs3"; 
      options = [ "rw" "uid=1000"];
    };

  system.stateVersion = "22.11";
}
