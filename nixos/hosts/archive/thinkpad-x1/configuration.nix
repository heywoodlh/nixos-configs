# Config specific to Lenovo ThinkPad X1

{ config, pkgs, lib, ... }:

{
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
      ../../desktop.nix
      ../../roles/gnome-boxes.nix
    ];

  # Bootloader
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.loader.efi.efiSysMountPoint = "/boot/efi";

  # Setup keyfile
  boot.initrd.secrets = {
    "/crypto_keyfile.bin" = null;
  };

  # Deep sleep
  boot.kernelParams = [ "mem_sleep_default=deep" ];

  networking.hostName = "nix-thinkpad"; # Define your hostname.

  # Enable networking
  networking.networkmanager.enable = true;
  # Set DNS
  #networking.nameservers = [ "10.50.50.1" ];
  #environment.etc = {
  #  "resolv.conf".text = "nameserver 10.50.50.1\n";
  #};

  # Set your time zone.
  time.timeZone = "America/Denver";

  # Select internationalisation properties.
  i18n.defaultLocale = "en_US.utf8";

  ## Hardware acceleration for Intel graphics
  hardware.opengl = {
    enable = true;
    extraPackages = with pkgs; [
      intel-media-driver # LIBVA_DRIVER_NAME=iHD
      vaapiIntel         # LIBVA_DRIVER_NAME=i965 (older but works better for Firefox/Chromium)
      vaapiVdpau
      libvdpau-va-gl
    ];
  };

  #systemd.services = {
  #  wireguard = {
  #    enable = true;
  #    description = "Wireguard on Demand Service";
  #    serviceConfig = {
  #      ExecStart = "/opt/scripts/wireguard.sh";
  #    };
  #    wantedBy = [ "multi-user.target" ];
  #  };
  #  wireguard-wired = {
  #    enable = true;
  #    description = "Wireguard on Demand Ethernet Service";
  #    serviceConfig = {
  #      ExecStart = "/opt/scripts/wireguard-wired.sh";
  #    };
  #    wantedBy = [ "multi-user.target" ];
  #  };
  #};

  # Enable fprint
  environment.systemPackages = [
    pkgs.fprintd
  ];
  services.fprintd.enable = true;
  services.fprintd.tod.enable = true;
  services.fprintd.tod.driver = pkgs.libfprint-2-tod1-vfs0090;

  # Set version of NixOS to target
  system.stateVersion = "22.11";

}
