{ modulesPath, lib, config, pkgs, ... }:
with lib;

{
  imports = [
    (modulesPath + "/installer/scan/not-detected.nix")
  ];

  boot.initrd.availableKernelModules = [ "nvme" "xhci_pci" "usb_storage" "usbhid" "sd_mod" "sdhci_pci" ];
  boot.initrd.kernelModules = [ ];
  boot.kernelModules = [ "kvm-amd" ];
  boot.extraModulePackages = [ ];

  environment.systemPackages = with pkgs; [
    moonlight-qt
  ];

  fileSystems."/" = {
    device = "/dev/disk/by-uuid/adf380ab-a702-4976-b107-cb6547629a1e";
    fsType = "ext4";
  };

  fileSystems."/boot" = {
    device = "/dev/disk/by-uuid/32B9-2D4B";
    fsType = "vfat";
    options = [ "fmask=0022" "dmask=0022" ];
  };

  fileSystems."/mnt/sdcard" = {
    device = "/dev/mmcblk0p1";
    fsType = "ext4";
    options = [
      "nofail"
      "x-systemd.automount"
    ];
  };

  swapDevices = [
    {
      device = "/dev/disk/by-uuid/78920e10-3d0a-4460-98a7-af1513c6a6df";
    }
  ];

  nixpkgs.hostPlatform = mkDefault "x86_64-linux";
  hardware.cpu.amd.updateMicrocode = mkDefault config.hardware.enableRedistributableFirmware;
}
