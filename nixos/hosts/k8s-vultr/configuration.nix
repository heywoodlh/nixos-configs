{ config, pkgs, lib, ... }:

{
  imports =
  [ # Include the results of the hardware scan.
    /etc/nixos/hardware-configuration.nix
    ../../server.nix
    ../../roles/containers/k3s.nix
  ];

  # Bootloader.
  boot.loader.grub.enable = true;
  boot.loader.grub.device = "/dev/vda";

  # Enable networking
  networking.networkmanager.enable = true;

  # Set your time zone.
  time.timeZone = "America/Denver";

  # Select internationalisation properties.
  i18n.defaultLocale = "en_US.utf8";

  # K8s cluster
  services.k3s = {
    role = "server";
    tokenFile = "/root/k3s-token";
    serverAddr = "https://100.108.77.60:6443";
  };
}
