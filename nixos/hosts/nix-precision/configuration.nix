{ config, pkgs, ... }:

{
  imports =
  [ # Include the results of the hardware scan.
    ./hardware-configuration.nix
    ../../server.nix
    ../../roles/libvirt.nix
    ../../roles/iperf.nix
    ../../roles/monitoring/scrutiny.nix
  ];

  # Bootloader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.loader.efi.efiSysMountPoint = "/boot/efi";

  # Enable networking
  networking.networkmanager.enable = true;
  networking.hostName = "nix-precision"; # Define your hostname

  # Set your time zone.
  time.timeZone = "America/Denver";

  # Select internationalisation properties.
  i18n.defaultLocale = "en_US.utf8";

    # Enable auto upgrade
  system.autoUpgrade = {
    enable = true;
    flake = "github:heywoodlh/nixos-configs#nix-precision";
  };

  # Virtual machine media
  fileSystems."/media/virtual-machines" = {
    device = "/dev/disk/by-uuid/2fa5a6c4-b938-4853-844d-c85a77ae33e7";
    fsType = "ext4";
    options = [ "rw" "relatime" ];
  };

  fileSystems."/media/virtual-machines-2" = {
    device = "/dev/disk/by-uuid/b1d9e75f-df2c-4ec0-a691-71aebf100cd6";
    fsType = "ext4";
    options = [ "discard" "noatime" "commit=600" "errors=remount-ro" ];
  };

  virtualisation.oci-containers.containers.scrutiny.extraOptions = [
    "--device=/dev/sda"
    "--device=/dev/sdc"
    "--device=/dev/sdf"
  ];

  system.stateVersion = "22.11";
}
