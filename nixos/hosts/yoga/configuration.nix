# Config specific to Lenovo Thinkpad Yoga

{ config, pkgs, lib, ... }:

{
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
      ../../desktop.nix
    ];

  # Bootloader
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.loader.efi.efiSysMountPoint = "/boot/efi";

  # Setup keyfile
  boot.initrd.secrets = {
    "/crypto_keyfile.bin" = null;
  };


  networking.hostName = "nix-yoga"; # Define your hostname.

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

  home-manager.users.heywoodlh = {
    home.packages = with pkgs; [
      spotify-tui
      rustdesk
    ];
    ## Spotify config
    services.spotifyd = {
      enable = true;
      settings = {
        global = {
          username = "31los4pph7awxi3i2inw5xiyut4u";
          password_cmd = "cat ~/.config/spotifyd/password.txt";
          device_name = "nix";
        };
      };
    };
  };

  # Hardware config specific to Lenovo Yoga 7i
  # Arch Wiki was helpful: https://wiki.archlinux.org/title/Lenovo_Yoga_7i
  hardware.sensor.iio.enable = true;
  boot.kernelParams = [ "mem_sleep_default=s2idle" "ideapad_laptop" ];
  services.power-profiles-daemon.enable = true;
  services.fprintd.tod.driver = pkgs.libfprint-2-tod1-goodix-550a;
  environment.systemPackages = with pkgs; [
    gnomeExtensions.ideapad
  ];
  # Enable fprint
  services.fprintd.enable = true;
  services.fprintd.tod.enable = true;

  # Set version of NixOS to target
  system.stateVersion = "23.05";
}
