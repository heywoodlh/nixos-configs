{ config, lib, pkgs, modulesPath, ... }:

{
  imports =
    [ (modulesPath + "/installer/scan/not-detected.nix")
    ];

  boot.initrd.availableKernelModules = [ "ahci" "xhci_pci" "vmd" "usbhid" "usb_storage" "sd_mod" "sr_mod" ];
  boot.initrd.kernelModules = [ ];
  boot.kernelModules = [ "kvm-intel" ];
  boot.extraModulePackages = [ ];

  fileSystems."/" =
    { device = "/dev/disk/by-uuid/d971d77c-33ac-469b-a481-6b187454efbd";
      fsType = "ext4";
    };

  fileSystems."/boot" =
    { device = "/dev/disk/by-uuid/ED47-8DFE";
      fsType = "vfat";
      options = [ "fmask=0077" "dmask=0077" ];
    };

  swapDevices = [ ];

  # Enables DHCP on each ethernet and wireless interface. In case of scripted networking
  # (the default) this is the recommended approach. When using systemd-networkd it's
  # still possible to use this option, but it's recommended to use it in conjunction
  # with explicit per-interface declarations with `networking.interfaces.<interface>.useDHCP`.
  networking.useDHCP = lib.mkDefault true;
  # networking.interfaces.enp0s31f6.useDHCP = lib.mkDefault true;
  # networking.interfaces.enp2s0.useDHCP = lib.mkDefault true;

  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
  hardware.cpu.intel.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;

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
    sunshine_name = "sarah-linux";
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
      allowedUDPPorts = [
        9
        5353 # shanocast
      ];
    };
  };

  # Allow mdns for shanocast
  services.avahi = {
    enable = true;
    reflector = true;
    openFirewall = true;
  };

  home-manager.users.heywoodlh = let
    apple-music = pkgs.writeShellScriptBin "apple-music" ''
      ${pkgs.google-chrome}/bin/google-chrome-stable --password-store=basic --app=https://music.apple.com
    '';
    apple-music-desktop = {
      name = "Apple Music";
      command = "${apple-music}/bin/apple-music";
    };
  in {
    heywoodlh.home = {
      applications = [
        apple-music-desktop
      ];
      autostart = [
        apple-music-desktop
      ];
    };
  };

  fileSystems."/mnt/ssd0" = {
    device = "/dev/disk/by-uuid/767C97A37C975D25";
    fsType = "ntfs-3g";
    options = [ "rw" "uid=1000" "nofail" ];
  };
  fileSystems."/mnt/windows" = {
    device = "/dev/disk/by-uuid/C2E61A2DE61A21E9";
    fsType = "ntfs-3g";
    options = [ "rw" "uid=1000" "nofail" ];
  };
  fileSystems."/mnt/hdd0" = {
    device = "/dev/disk/by-uuid/00CA2333CA2323FE";
    fsType = "ntfs-3g";
    options = [ "rw" "uid=1000" "nofail" ];
  };
  fileSystems."/mnt/hdd1" = {
    device = "/dev/disk/by-uuid/3008899808895E2A";
    fsType = "ntfs-3g";
    options = [ "rw" "uid=1000" "nofail" ];
  };
}
