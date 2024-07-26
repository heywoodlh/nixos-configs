# Config specific to Dell XPS 13
{ config, pkgs, lib, spicetify, nixos-x13s, ... }:

{
  imports =
    [ # Include the results of the hardware scan.
      inputs.nixos-x13s.nixosModules.default
      /etc/nixos/hardware-configuration.nix
      ../desktop=.nix
    ];

  nixos-x13s = {
    enable = true;
    kernel = "jhovold";
    bluetoothMac = "02:68:b3:29:da:98";
  };
  specialisation = {
    mainline.configuration.nixos-x13s.kernel = "jhovold";
  };
  nix.settings = {
    substituters = [
      "https://heywoodlh-nixos-x13s.cachix.org"
    ];
    trusted-public-keys = [
      "heywoodlh-nixos-x13s.cachix.org-1:nittOYRA74tbzQ1s92ZQbN61ecxo7Ld16LK3g+CPPSE="
    ];
  };

  networking.hostName = "nixos-thinkpad";
  # Bootloader
  boot.loader.systemd-boot.enable = true;
  # Enable networking
  networking.networkmanager.enable = true;
  # Set your time zone.
  time.timeZone = "America/Denver";
  # Select internationalisation properties.
  i18n.defaultLocale = "en_US.utf8";

  # Fingerprint
  services.fprintd.enable = true;
  services.fprintd.tod.enable = true;
  services.fprintd.tod.driver = pkgs.libfprint-2-tod1-goodix;

  # Network manager modemmanager setup
  networking.networkmanager.fccUnlockScripts = [
    {
      id = "105b:e0c3";
      path = "${pkgs.modemmanager}/share/ModemManager/fcc-unlock.available.d/105b";
    }
  ];

  environment.systemPackages = with pkgs; [
    webcord
  ];

  system.stateVersion = "24.05";
}
