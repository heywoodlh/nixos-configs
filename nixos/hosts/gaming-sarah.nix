{ config, lib, pkgs, modulesPath, ... }:

with lib;

let
  aveyond = pkgs.writeShellScriptBin "aveyond.sh" ''
    WINEPREFIX=$HOME/.wine \
    WINEDLLOVERRIDES="quartz=d" \
      ${pkgs.umu-launcher}/bin/umu-run /home/heywoodlh/.wine/drive_c/Program\ Files\ \(x86\)/Aveyond/Game.exe
  '';
  aveyond-eans-quest = pkgs.writeShellScriptBin "aveyond-eans-quest.sh" ''
    ${pkgs.umu-launcher}/bin/umu-run /home/heywoodlh/.wine/drive_c/Program\ Files\ \(x86\)/Aveyond\ 2\ -\ Ean\'s\ Quest/Aveyond\ 2.exe
  '';
in {
  imports = [
    (modulesPath + "/installer/scan/not-detected.nix")
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

  swapDevices = [
    {
      device = "/swap";
      size = 16 * 1024;
    }
  ];

  networking.useDHCP = lib.mkDefault true;

  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
  hardware.cpu.intel.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;

  heywoodlh.nixos = {
    tor.enable = mkForce false;
    gaming = {
      enable = true;
      console = true;
    };
    libvirtd.enable = false;
    # Machine-specific sunshine configuration
    sunshine.extraConfig = {
      sunshine_name = "sarah-linux";
      output_name = 0;
      encoder = "nvenc";
      nvenc_preset = 1;
      csrf_allowed_origins = "https://nixos-gaming-sarah.barn-banana.ts.net:47990,https://192.168.1.196:47990,https://sunshine-sarah.heywoodlh.io";
    };
  };

  #boot.loader.systemd-boot.edk2-uefi-shell.enable = true;
  boot.loader.systemd-boot.windows."11".efiDeviceHandle = "HD1i32768a1";

  environment.systemPackages = let
    reboot-windows = pkgs.writeShellScriptBin "reboot-windows" ''
      sudo ${pkgs.systemd}/bin/systemctl --boot-loader-entry="windows_11.conf" reboot
    '';
  in with pkgs; [
    steam-run
    reboot-windows
    clonehero
    aveyond
    aveyond-eans-quest
  ];

  networking = {
    interfaces = {
      enp4s0 = {
        wakeOnLan.enable = true;
      };
    };
    firewall = {
      interfaces.enp2s0.allowedTCPPorts = [ 47990 ];
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

  security.sudo.extraConfig = ''
    heywoodlh ALL=(ALL) NOPASSWD:/run/current-system/sw/bin/reboot-windows
  '';

  # Enable 32 bit audio for Aveyond/older games
  services.pulseaudio.support32Bit = true;

  fileSystems."/mnt/ssd0" = {
    device = "/dev/disk/by-uuid/767C97A37C975D25";
    fsType = "ntfs3";
    options = [ "rw" "uid=1000" "nofail" ];
  };
  fileSystems."/mnt/windows" = {
    device = "/dev/disk/by-uuid/C2E61A2DE61A21E9";
    fsType = "ntfs3";
    options = [ "rw" "uid=1000" "nofail" ];
  };
  fileSystems."/mnt/hdd0" = {
    device = "/dev/disk/by-uuid/00CA2333CA2323FE";
    fsType = "ntfs3";
    options = [ "rw" "uid=1000" "nofail" ];
  };
  fileSystems."/mnt/hdd1" = {
    device = "/dev/disk/by-uuid/3008899808895E2A";
    fsType = "ntfs3";
    options = [ "rw" "uid=1000" "nofail" ];
  };
}
