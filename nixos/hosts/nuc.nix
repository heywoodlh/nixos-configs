{ config, lib, pkgs, modulesPath, ... }:

{
  imports =
    [ (modulesPath + "/installer/scan/not-detected.nix")
    ];

  boot.initrd.availableKernelModules = [ "xhci_pci" "ahci" "usb_storage" "usbhid" "sd_mod" ];
  boot.initrd.kernelModules = [ ];
  boot.kernelModules = [ "kvm-amd" ];
  boot.extraModulePackages = [ ];

  fileSystems."/" =
    { device = "/dev/disk/by-uuid/d3ee753d-ab2f-4d3d-b933-eafaf2aba411";
      fsType = "ext4";
    };

  fileSystems."/boot" =
    { device = "/dev/disk/by-uuid/6F81-463B";
      fsType = "vfat";
      options = [ "fmask=0077" "dmask=0077" ];
    };

  swapDevices =
    [ { device = "/dev/disk/by-uuid/8a404ba6-b8b5-403a-bc3d-baf5150c2dde"; }
    ];

  heywoodlh.nixos.remote-desktop = {
    enable = true;
    tailscaleIP = "100.74.91.97";
  };

  services.desktopManager.plasma6.enable = false;
  services.displayManager = {
    gdm.enable = true;
    defaultSession = "hyprland";
    autoLogin = {
      enable = true;
      user = config.heywoodlh.defaults.user.name;
    };
  };
  heywoodlh.cosmic = lib.mkForce false;
  heywoodlh.hyprland = true;
  heywoodlh.nixos.kde.enable = false;
  heywoodlh.nixos.sunshine.enable = false;

  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
  hardware.cpu.amd.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;
}
