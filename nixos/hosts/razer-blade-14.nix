{ config, lib, pkgs, modulesPath, ... }:

{
  imports =
    [ (modulesPath + "/installer/scan/not-detected.nix")
    ];

  services.logind.settings.Login.HandleLidSwitch = "suspend-then-hibernate";
  services.logind.settings.Login.HandleLidSwitchExternalPower = "lock";
  services.logind.settings.Login.HandleLidSwitchDocked = "ignore";

  hardware.openrazer.enable = true;
  services.thermald.enable = true;

  boot.initrd.availableKernelModules = [ "nvme" "xhci_pci" "usb_storage" "usbhid" "sd_mod" ];
  boot.kernelModules = [ "kvm-amd" ];
  boot.extraModulePackages = [ ];
  fileSystems."/" =
    { device = "/dev/disk/by-uuid/7cea21bf-8580-472a-8b59-355d62ee1ee3";
      fsType = "ext4";
    };
  boot.initrd.luks.devices."luks".device = "/dev/disk/by-uuid/ae2132a2-325c-4418-b42b-0492e9c7c448";
  fileSystems."/boot" =
    { device = "/dev/disk/by-uuid/6040-B029";
      fsType = "vfat";
      options = [ "fmask=0077" "dmask=0077" ];
    };
  swapDevices =
    [
      {
        device = "/swap";
        size = 16 * 1024;
      }
    ];
  networking.useDHCP = lib.mkDefault true;
  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
  hardware.cpu.amd.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;

  # Automatic LUKS decryption with Yubikey
  heywoodlh.luks = {
    enable = true;
    boot = "/dev/nvme0n1p1";
    name = "luks";
    uuid = "ae2132a2-325c-4418-b42b-0492e9c7c448";
    fido = true; # Setup with `sudo systemd-cryptenroll /dev/nvme0n1p2 --fido2-device=auto --fido2-with-user-presence=yes --fido2-with-client-pin=no`
  };
}
