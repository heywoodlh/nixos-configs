{ config, lib, pkgs, modulesPath, stackpkgs, ... }:

{
  imports =
    [ (modulesPath + "/installer/scan/not-detected.nix")
    ];

  boot.initrd.availableKernelModules = [ "nvme" "xhci_pci" "ahci" "usb_storage" "usbhid" "sd_mod" ];
  boot.initrd.kernelModules = [ ];
  boot.kernelModules = [ ];
  boot.extraModulePackages = [ ];

  fileSystems."/" =
    { device = "/dev/disk/by-uuid/2eadbaea-d13c-4899-8126-8b28cef34d78";
      fsType = "ext4";
    };

  fileSystems."/boot" =
    { device = "/dev/disk/by-uuid/0B6C-A915";
      fsType = "vfat";
      options = [ "fmask=0077" "dmask=0077" ];
    };

  swapDevices = [ ];

  # Enables DHCP on each ethernet and wireless interface. In case of scripted networking
  # (the default) this is the recommended approach. When using systemd-networkd it's
  # still possible to use this option, but it's recommended to use it in conjunction
  # with explicit per-interface declarations with `networking.interfaces.<interface>.useDHCP`.
  networking.useDHCP = lib.mkDefault true;
  # networking.interfaces.enp4s0.useDHCP = lib.mkDefault true;

  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
  hardware.cpu.amd.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;

  heywoodlh.nixos.gaming = {
    enable = true;
    console = true;
  };

  environment.systemPackages = let
    reboot-windows = pkgs.writeShellScriptBin "reboot-windows" ''
      sudo ${pkgs.systemd}/bin/systemctl --boot-loader-entry=auto-windows reboot
    '';
  in with pkgs; [
    steam-run
    reboot-windows
    clonehero
  ];
  # Machine-specific sunshine configuration
  services.sunshine.settings = {
    sunshine_name = "nixos-gaming";
    output_name = 0;
    encoder = "nvenc";
    nvenc_preset = 1;
  };
  networking = {
    interfaces = {
      enp4s0 = {
        wakeOnLan.enable = true;
      };
    };
    firewall = {
      allowedTCPPorts = [
        59100 # AudioRelay
      ];
      allowedUDPPorts = [
        9
        59100 # AudioRelay
        59200 # AudioRelay server discovery
      ];
    };
  };
  fileSystems."/mnt/hdd0" = {
    device = "/dev/disk/by-uuid/2292D29C92D273AF";
    fsType = "ntfs-3g";
    options = [ "rw" "uid=1000" "nofail" ];
  };
  fileSystems."/mnt/ssd0" = {
    device = "/dev/disk/by-uuid/5D8A245A63983818";
    fsType = "ntfs-3g";
    options = [ "rw" "uid=1000" "nofail" ];
  };
  fileSystems."/mnt/windows" = {
    device = "/dev/disk/by-uuid/360C7E6F0C7E29CF";
    fsType = "ntfs-3g";
    options = [ "rw" "uid=1000" "nofail" ];
  };

  # Allow mdns for shanocast
  services.avahi = {
    enable = true;
    reflector = true;
    openFirewall = true;
  };

  home-manager.users.heywoodlh = {
    home.packages = with pkgs; [
      ytmdesktop
      (pkgs.callPackage "${stackpkgs}/packages/audiorelay.nix" {})
    ];
    heywoodlh.home = {
      autostart = [
        {
          name = "AudioRelay";
          command = "${pkgs.callPackage "${stackpkgs}/packages/audiorelay.nix" {}}/bin/audiorelay";
        }
      ];
    };
  };
}
