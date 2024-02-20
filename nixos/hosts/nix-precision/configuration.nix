{ config, pkgs, nixpkgs-backports, ... }:

let
  system = pkgs.system;
in {
  imports =
  [ # Include the results of the hardware scan.
    ./hardware-configuration.nix
    ../../server.nix
    ../../roles/virtualization/libvirt.nix
    ../../roles/monitoring/iperf.nix
    ../../roles/monitoring/scrutiny.nix
    ../../roles/remote-access/cockpit.nix
    ../../roles/storage/nfs-kube.nix
    ../../roles/storage/nfs-media.nix
    ../../roles/storage/webdav-media.nix
    ../../roles/media/plex.nix
    ../../roles/monitoring/scrutiny.nix
  ];

  # Bootloader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.loader.efi.efiSysMountPoint = "/boot/efi";
  boot.supportedFilesystems = [
    "ext4"
    "btrfs"
    "vfat"
    "xfs"
    "ntfs"
    "cifs"
  ];

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
    "--device=/dev/sdb"
    "--device=/dev/sdc"
    "--device=/dev/sdd"
    "--device=/dev/sde"
    "--device=/dev/sdf"
  ];

  fileSystems."/media/home-media/disk1" = {
    device = "/dev/disk/by-uuid/8f645e4b-0544-4ce9-8797-7dfe7f85df5a";
    fsType = "btrfs";
  };

  fileSystems."/media/home-media/disk2" = {
    device = "/dev/disk/by-uuid/7d1d10dd-392d-47ce-b178-bffd2295637e";
    fsType = "btrfs";
  };

  # Nvidia driver
  hardware.nvidia.package = config.boot.kernelPackages.nvidiaPackages.stable;
  hardware.opengl = {
    enable = true;
    driSupport = true;
    driSupport32Bit = true;
  };
  services.xserver.videoDrivers = ["nvidia"];
  hardware.nvidia = {
    modesetting.enable = true;
  };

  system.stateVersion = "23.11";
}
