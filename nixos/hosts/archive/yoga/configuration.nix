# Config specific to Lenovo Thinkpad Yoga

{ config, pkgs, lib, spicetify, ... }:

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
    imports = [
      ../../../roles/home-manager/linux/hyprland/spotify.nix
      ../../../roles/home-manager/linux/hyprland/laptop.nix
      ../../../roles/home-manager/linux/hyprland/office-monitors.nix
    ];
    home.packages = with pkgs; [
      remmina
      signal-desktop
      spicetify.packages.x86_64-linux.nord
      zoom-us
    ];
  };

  # Allow PAM to use Yubikey for auth
  # Setup with these commands:
  # nix-shell -p yubico-pam -p yubikey-manager
  # pamu2fcfg -NP > ~/.config/Yubico/u2f_keys
  security.pam.u2f = {
    enable = true;
    control = "sufficient";
  };

  # Hardware config specific to Lenovo Yoga 7i
  # Arch Wiki was helpful: https://wiki.archlinux.org/title/Lenovo_Yoga_7i
  hardware.sensor.iio.enable = true;
  boot.kernelParams = [ "mem_sleep_default=s2idle" "ideapad_laptop" ];
  services.power-profiles-daemon.enable = true;

  # Set version of NixOS to target
  system.stateVersion = "23.05";
}
