{
  config,
  lib,
  pkgs,
  inputs,
  ...
}: {
  imports = [inputs.disko.nixosModules.disko];

  disko.devices = {
    disk.main = {
      type = "disk";
      device = "/dev/nvme0n1";
      content = {
        type = "gpt";
        partitions = {
          ESP = {
            type = "EF00";
            size = "1G";
            content = {
              type = "filesystem";
              format = "vfat";
              mountpoint = "/boot";
              mountOptions = ["fmask=0077" "dmask=0077"];
            };
          };
          root = {
            size = "100%";
            content = {
              type = "luks";
              name = "cryptroot";
              settings.allowDiscards = true;
              content = {
                type = "gpt";
                partitions = {
                  root = {
                    size = "100%";
                    content = {
                      type = "filesystem";
                      format = "ext4";
                      mountpoint = "/";
                    };
                  };
                  swap = {
                    size = "8G";
                    content = {
                      type = "swap";
                      discardPolicy = "both";
                    };
                  };
                };
              };
            };
          };
        };
      };
    };
  };

  boot.initrd.availableKernelModules = [
    "nvme"
    "xhci_pci"
    "thunderbolt"
    "usb_storage"
    "uas"
    "sd_mod"
    "usbhid"
    "vfat"
    "nls_cp437"
    "nls_iso8859-1"
  ];
  boot.kernelModules = ["kvm-intel"];
  boot.kernelParams = ["i915.enable_psr=1"];

  networking.useDHCP = lib.mkDefault true;
  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
  hardware.enableRedistributableFirmware = true;
  hardware.cpu.intel.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;
  hardware.graphics.extraPackages = [pkgs.intel-media-driver];

  services.thermald.enable = true;
  services.fwupd.enable = true;

  security.pam.services.sudo.fprintAuth = true;
  services.fprintd.enable = true;
  heywoodlh.fprintLid.enable = true;
  heywoodlh.fprintLid.path = "/proc/acpi/button/lid/LID0/state";

  services.logind.settings.Login = {
    HandleLidSwitch = "suspend";
    HandleLidSwitchExternalPower = "suspend";
    HandleLidSwitchDocked = "ignore";
  };

  environment.systemPackages = with pkgs; [
    sbctl
  ];
}
