{
  lib,
  pkgs,
  modulesPath,
  ...
}: {
  imports = [
    (modulesPath + "/installer/scan/not-detected.nix")
  ];

  fileSystems."/" = {
    device = "/dev/mapper/luks";
    fsType = "ext4";
  };

  boot.initrd.availableKernelModules = ["xhci_pci" "usbhid" "usb_storage"];

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

  fileSystems."/boot" = {
    device = "/dev/disk/by-uuid/337C-1416";
    fsType = "vfat";
    options = ["fmask=0022" "dmask=0022"];
  };

  # This ESP is only 476M; each kernel+initrd pair is ~90M. Without a limit,
  # systemd-boot keeps every generation's entry until it runs out of space,
  # which silently corrupts the newest write (see 2026-08-25 boot failures).
  boot.loader.systemd-boot.configurationLimit = 3;

  swapDevices = [
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
  boot.kernelPatches = [
    {
      name = "asahi-kernel-compat";
      patch = null;
      structuredExtraConfig = {
        HAMRADIO = lib.mkOverride 49 (lib.kernel.option lib.kernel.no);
      };
    }
  ];

  heywoodlh = {
    luks = {
      enable = true;
      uuid = "22d52b85-5679-4d18-a245-974fab33bf7f";
      keyfile = {
        enable = true;
        uuid = "337C-1416";
      };
    };
    sshd.enable = true;
    nixos = {
      gaming.enable = false;
      moonlight.enable = true;
    };
    apple-silicon = {
      enable = true;
      cachefile = "kernelcache.release.mac13g";
      hash = {
        cache = "sha256-SYR/EaaIDjeGfvhfzlTqgOihXNQQdBgqJbBJbq+wC9g=";
        firmware = "sha256-Q/WI5j9fltdGN5osDzk66iVkWgS9SpD4dqpHLOSeebc=";
      };
    };
  };

  boot.loader.efi.canTouchEfiVariables = lib.mkForce false;
  boot.kernelParams = ["hid_apple.swap_fn_leftctrl=1"];
  boot.kernelModules = ["hid_microsoft" "uinput"];

  services.udev.packages = [
    (pkgs.writeTextFile {
      name = "xbox-hidraw-udev-rules";
      text = ''KERNEL=="hidraw*", TAG+="uaccess"'';
      destination = "/etc/udev/rules.d/60-xbox-hidraw.rules";
    })
  ];

  fileSystems."/mnt/m1-mac-mini" = {
    device = "/dev/disk/by-uuid/6968-012B";
    fsType = "exfat";
    options = ["rw" "uid=1000" "nofail"];
  };

  home-manager.users.heywoodlh = {
    heywoodlh.home.paseo = {
      desktop = true;
      server = {
        enable = true;
        address = "100.109.94.126:6767";
        hostnames = [
          "nixos-m1-mac-mini"
          "nixos-m1-mac-mini.barn-banana.ts.net"
        ];
      };
    };

    wayland.windowManager.niri.extraConfig = ''
      output "eDP-1" {
        scale 1
      }
    '';
    home.sessionVariables = {
      GDK_SCALE = "2";
      XCURSOR_SIZE = "24";
    };
  };
}
