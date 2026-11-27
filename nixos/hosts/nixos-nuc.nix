{
  config,
  lib,
  modulesPath,
  ...
}: {
  imports = [
    (modulesPath + "/installer/scan/not-detected.nix")
  ];

  boot.initrd.availableKernelModules = ["xhci_pci" "ahci" "usb_storage" "usbhid" "sd_mod"];
  boot.initrd.kernelModules = [];
  boot.kernelModules = ["kvm-amd"];
  boot.extraModulePackages = [];

  fileSystems."/" = {
    device = "/dev/disk/by-uuid/d3ee753d-ab2f-4d3d-b933-eafaf2aba411";
    fsType = "ext4";
  };

  fileSystems."/boot" = {
    device = "/dev/disk/by-uuid/6F81-463B";
    fsType = "vfat";
    options = ["fmask=0077" "dmask=0077"];
  };

  swapDevices = [
    {device = "/dev/disk/by-uuid/8a404ba6-b8b5-403a-bc3d-baf5150c2dde";}
  ];

  hardware.graphics = {
    enable = true;
    enable32Bit = true;
  };

  heywoodlh = {
    cloudflared = true;
    sshd = {
      enable = true;
      duo = true;
    };
    nixos.scrutiny = {
      enable = true;
      port = 3050;
      ntfy = "ntfy://ntfy.barn-banana.ts.net/monitoring";
    };
  };

  systemd.targets = {
    sleep.enable = false;
    suspend.enable = false;
    hibernate.enable = false;
    hybrid-sleep.enable = false;
  };

  boot.kernelParams = ["hid_apple.swap_fn_leftctrl=1"];

  networking.firewall.interfaces.tailscale0.allowedTCPPorts = [3773];

  nix.settings = {
    max-jobs = 1;
    cores = 4;
  };

  systemd.services.nix-daemon.serviceConfig.MemoryHigh = "3G";

  home-manager.users.heywoodlh.heywoodlh.home = {
    paseo = {
      desktop = true;
      server = {
        enable = true;
        address = "100.74.91.97:6767";
        hostnames = [
          "nixos-nuc"
          "nixos-nuc.barn-banana.ts.net"
        ];
      };
    };
    t3 = {
      enable = true;
      address = "100.74.91.97";
    };
  };

  heywoodlh.nixos.remote-desktop = {
    enable = true;
    address = "100.74.91.97";
    cssScaling = true;
    headless.enable = true;
  };

  home-manager.users.heywoodlh.heywoodlh.home.spotify-soloist.enable = true;

  services.displayManager.gdm.enable = lib.mkForce false;
  services.xserver.displayManager.lightdm.enable = lib.mkForce false;
  heywoodlh.cosmic = lib.mkForce false;
  heywoodlh.nixos.kde.enable = false;
  heywoodlh.nixos.sunshine.enable = false;

  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
  hardware.cpu.amd.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;
}
