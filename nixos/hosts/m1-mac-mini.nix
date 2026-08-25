{ config, lib, pkgs, modulesPath, ... }:

{
  imports =
    [ (modulesPath + "/installer/scan/not-detected.nix")
    ];

  fileSystems."/" =
    { device = "/dev/mapper/luks";
      fsType = "ext4";
    };

  boot.initrd.availableKernelModules = [ "xhci_pci" "usbhid" "usb_storage" ];

  # LUKS stuff all in flake.nix now
  #boot.initrd = {
    # Yubikey challenge-response LUKS is not supported in systemd stage 1;
    # nixpkgs now defaults boot.initrd.systemd.enable to true, so override it.
    #luks = {
    #  devices."luks" = {
    #    device = "/dev/disk/by-uuid/22d52b85-5679-4d18-a245-974fab33bf7f";
    #  };
    #};
  #};

  fileSystems."/boot" =
    { device = "/dev/disk/by-uuid/337C-1416";
      fsType = "vfat";
      options = [ "fmask=0022" "dmask=0022" ];
    };

  # This ESP is only 476M; each kernel+initrd pair is ~90M. Without a limit,
  # systemd-boot keeps every generation's entry until it runs out of space,
  # which silently corrupts the newest write (see 2026-08-25 boot failures).
  boot.loader.systemd-boot.configurationLimit = 3;

  swapDevices =
    [
      {
        device = "/swap";
        size = 16 * 1024;
      }
    ];

  nixpkgs.hostPlatform = lib.mkDefault "aarch64-linux";

  # The kyle appleSilicon module sets HAMRADIO = lib.mkForce lib.kernel.no (non-optional),
  # but this option doesn't exist in the Asahi kernel. Override it with higher priority
  # (mkOverride 49 beats mkForce's 50) to make it optional and prevent the config build
  # from failing. Add other options here if future kernel bumps break on them too.
  boot.kernelPatches = [{
    name = "asahi-kernel-compat";
    patch = null;
    structuredExtraConfig = {
      HAMRADIO = lib.mkOverride 49 (lib.kernel.option lib.kernel.no);
    };
  }];
}
