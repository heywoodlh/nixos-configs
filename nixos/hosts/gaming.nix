{ config, lib, pkgs, modulesPath, stackpkgs, ... }:

with lib;
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
  networking.useDHCP = mkDefault true;
  # networking.interfaces.enp4s0.useDHCP = lib.mkDefault true;

  nixpkgs.hostPlatform = mkDefault "x86_64-linux";
  hardware.cpu.amd.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;

  heywoodlh.nixos = {
    tor.enable = mkForce false;
    gaming = {
      enable = true;
      console = true;
      soulframe = true;
    };
    libvirtd.enable = false;
    # Machine-specific sunshine configuration
    sunshine.extraConfig = {
      sunshine_name = "spencer-linux";
      output_name = 0;
      encoder = "nvenc";
      nvenc_preset = 1;
      csrf_allowed_origins = "https://nixos-gaming.barn-banana.ts.net:47990,https://192.168.1.231:47990,https://sunshine.heywoodlh.io";
    };
  };

  environment.systemPackages = with pkgs; [
    steam-run
    clonehero
  ];

  networking = {
    interfaces = {
      enp4s0 = {
        wakeOnLan.enable = true;
      };
    };
    firewall = {
      interfaces.enp4s0.allowedTCPPorts = [ 47990 ];
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
    fsType = "ntfs3";
    options = [ "rw" "uid=1000" "nofail" ];
  };
  fileSystems."/mnt/ssd0" = {
    device = "/dev/disk/by-uuid/8eaf3cfd-1647-4454-9ad0-da35433582dd";
    fsType = "ext4";
    options = [ "defaults" "noatime" "nofail" ];
  };
  fileSystems."/mnt/internal" = {
    device = "/dev/disk/by-uuid/04c84a72-52b7-4de9-b736-a3d79d1ed80f";
    fsType = "ext4";
    options = [ "defaults" "noatime" "nofail" ];
  };

  # Allow mdns for shanocast
  services.avahi = {
    enable = true;
    reflector = true;
    openFirewall = true;
  };

  systemd.services.ntfsfix-startup = {
    description = "Fix NTFS dirty bit on /dev/sda1 before mounting";
    wantedBy = [ "mnt-hdd0.mount" ];
    before = [ "mnt-hdd0.mount" ];
    path = with pkgs; [ ntfsprogs util-linux ];
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
    };
    script = ''
      ntfsfix --clear-dirty /dev/sda1
    '';
  };

  home-manager.users.heywoodlh = {
    heywoodlh.home = {
      llm.lmstudio.enable = false;
      applications = let
        jackify = pkgs.writeShellScript "jackify" ''
          if nix profile list | grep -iq jackify
          then
            echo "Jackify already installed!"
          else
            notify-send "Downloading Jackify"
            nix profile add github:keygenesis/Jackify
          fi
          if [[ -e $HOME/.nix-profile/bin/jackify ]]
          then
            $HOME/.nix-profile/bin/jackify
          else
            notify-send "Jackify installation not found."
            exit 3
          fi
        '';
      in [
        {
          name = "Vortex";
          command = "${pkgs.umu-launcher}/bin/umu-run /mnt/ssd0/proton-apps/vortex/Vortex.exe";
        }
        {
          name = "Jackify";
          command = "${jackify}";
        }
      ];
    };
    home.packages = let
      #gamma-install = pkgs.writeShellScriptBin "gamma-install.sh" ''
        #${pkgs.gamma-launcher}/bin/gamma-launcher full-install --anomaly /mnt/ssd0/STALKER/ANOMALY --gamma /mnt/ssd0/STALKER/GAMMA --cache-directory /mnt/ssd0/STALKER/gamma-launcher-cache
        #${pkgs.gamma-launcher}/bin/gamma-launcher remove-reshade --anomaly /mnt/ssd0/STALKER/ANOMALY
      #'';
    in with pkgs; [
      #gamma-install
      ytmdesktop
      (pkgs.callPackage "${stackpkgs}/packages/audiorelay.nix" {})
    ];
  };
}
