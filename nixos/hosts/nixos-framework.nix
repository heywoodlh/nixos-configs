{
  config,
  lib,
  pkgs,
  modulesPath,
  lanzaboote,
  nixos-hardware,
  ...
}: {
  imports = [
    (modulesPath + "/installer/scan/not-detected.nix")
    lanzaboote.nixosModules.lanzaboote
    nixos-hardware.nixosModules.common-cpu-intel
    nixos-hardware.nixosModules.common-gpu-intel
    nixos-hardware.nixosModules.common-pc-laptop
    nixos-hardware.nixosModules.common-pc-laptop-ssd
  ];

  boot.initrd.availableKernelModules = ["xhci_pci" "thunderbolt" "nvme" "uas" "usb_storage" "sd_mod"];
  boot.initrd.kernelModules = [];
  boot.kernelModules = ["kvm-intel"];
  boot.extraModulePackages = [];

  fileSystems."/" = {
    device = "/dev/disk/by-uuid/556b75c1-9457-4d2f-9593-1df57439242b";
    fsType = "ext4";
  };

  boot.initrd.luks.devices."luks-d99babf3-d98d-4fa4-a368-672cdc27223e".device = "/dev/disk/by-uuid/d99babf3-d98d-4fa4-a368-672cdc27223e";

  fileSystems = {
    "/boot" = {
      device = "/dev/disk/by-uuid/5943-98C8";
      fsType = "vfat";
      options = ["fmask=0077" "dmask=0077"];
    };
    "/mnt/mod0" = {
      device = "/dev/disk/by-uuid/c166313e-13ea-42eb-9cc2-f84a0f2138ab";
      fsType = "ext4";
      options = [
        "nofail"
      ];
    };
  };

  swapDevices = [
    {
      device = "/swap";
      size = 16 * 1024;
    }
  ];

  networking.useDHCP = lib.mkDefault true;

  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
  hardware.cpu.intel.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;

  # Secure Boot setup:
  # https://community.frame.work/t/secureboot-setup-mode/14889/25
  # https://nix-community.github.io/lanzaboote/getting-started/prepare-your-system.html
  # Automatically decrypt LUKS partition with this command:
  # sudo systemd-cryptenroll --wipe-slot tpm2 --tpm2-device auto --tpm2-pcrs "1+7" /dev/nvme0n1p2
  # `nixos-rebuild` after
  boot.loader.systemd-boot.enable = lib.mkForce false; # using lanzaboote
  boot.lanzaboote = {
    enable = true;
    autoEnrollKeys.enable = true;
    pkiBundle = "/var/lib/sbctl";
  };

  users.users.heywoodlh.extraGroups = ["tss"];

  environment.systemPackages = with pkgs; [
    lanzaboote
    sbctl
  ];

  # Firmware updates
  services.fwupd.enable = true;

  # Fingerprint
  # setup with `sudo fprintd-enroll -f left-index-finger heywoodlh`
  security.pam.services.sudo.fprintAuth = true;
  services.fprintd.enable = true;

  heywoodlh.nixos = {
    gaming.enable = true;
    vmware-workstation = true;
    cachyos-kernel.enable = true;
    libvirtd.enable = true;
  };

  home-manager.users.heywoodlh = {
    wayland.windowManager.hyprland.extraConfig = ''
      -- change monitor to high resolution, the last argument is the scale factor
      hl.monitor({ output = "", mode = "highres", position = "auto", scale = 1.6 })
      -- unscale XWayland
      hl.config({ xwayland = { force_zero_scaling = true } })
      -- toolkit-specific scale
      hl.env("GDK_SCALE", "2")
      hl.env("XCURSOR_SIZE", "24")
    '';
    home.packages = with pkgs; [moonlight-qt];
  };
}
