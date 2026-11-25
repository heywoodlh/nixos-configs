{
  lib,
  nixos-lima,
  nixpkgs,
  ...
}: {
  imports = [
    nixos-lima.nixosModules.lima
    (nixpkgs + "/nixos/modules/profiles/qemu-guest.nix")
  ];

  heywoodlh = {
    sshd.enable = true;
    defaults = {
      enable = true;
      tailscale = false;
      syncthing = false;
    };
  };

  services.lima.enable = true;
  security.sudo.wheelNeedsPassword = false;

  boot.loader = {
    systemd-boot.enable = lib.mkForce false;
    efi.canTouchEfiVariables = lib.mkForce false;
    grub = {
      device = "nodev";
      efiSupport = true;
      efiInstallAsRemovable = true;
    };
  };

  fileSystems."/boot" = {
    device = lib.mkForce "/dev/vda1";
    fsType = "vfat";
  };

  fileSystems."/" = {
    device = "/dev/disk/by-label/nixos";
    autoResize = true;
    fsType = "ext4";
    options = [
      "noatime"
      "nodiratime"
      "discard"
    ];
  };
}
