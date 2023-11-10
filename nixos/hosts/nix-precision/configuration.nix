{ config, pkgs, nixpkgs-backports, ... }:

let
  system = pkgs.system;
  stable-pkgs = nixpkgs-backports.legacyPackages.${system};
in {
  imports =
  [ # Include the results of the hardware scan.
    ./hardware-configuration.nix
    ../../server.nix
    ../../roles/virtualization/libvirt.nix
    ../../roles/monitoring/iperf.nix
    ../../roles/monitoring/scrutiny.nix
    ../../roles/remote-access/cockpit.nix
    ../../roles/containers/k3s.nix
    #../../roles/media/plex.nix
    #../../roles/deluge.nix
    #../../roles/freshrss.nix
    #../../roles/oss-frontend.nix
    #../../roles/containers/syncthing.nix
    #../../roles/feeds/rsshub.nix
    #../../roles/feeds/miniflux.nix
    #../../roles/monitoring/scrutiny.nix
    #../../roles/storage/nfs-media.nix
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

  services.k3s = {
    package = stable-pkgs.k3s;
    extraFlags = toString [
      "--tls-san=nix-precision.tailscale"
      "--tls-san=nix-precision"
      "--tls-san=100.107.238.93"
    ];
  };

  fileSystems."/media/disk1" = {
    device = "/dev/disk/by-uuid/5f1975e9-ffde-4dbf-bd14-657bfb26287a";
    fsType = "btrfs";
  };

  fileSystems."/media/disk2" = {
    device = "/dev/disk/by-uuid/7d1d10dd-392d-47ce-b178-bffd2295637e";
    fsType = "btrfs";
  };

  system.stateVersion = "23.05";
}
