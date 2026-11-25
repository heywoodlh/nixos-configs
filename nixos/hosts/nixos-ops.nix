{
  config,
  lib,
  pkgs,
  modulesPath,
  ssh-keys,
  ...
}: {
  imports = [(modulesPath + "/installer/scan/not-detected.nix")];

  boot.initrd.availableKernelModules = ["xhci_pci" "ehci_pci" "nvme" "usbhid" "usb_storage" "sd_mod" "sr_mod" "sdhci_pci"];
  boot.initrd.kernelModules = [];
  boot.kernelModules = ["kvm-intel"];
  boot.extraModulePackages = [];

  fileSystems."/" = {
    device = "/dev/disk/by-uuid/a39f4f63-cf20-40cf-ac89-146ad2c978a5";
    fsType = "ext4";
  };

  fileSystems."/boot" = {
    device = "/dev/disk/by-uuid/5810-A4D5";
    fsType = "vfat";
    options = ["fmask=0077" "dmask=0077"];
  };

  swapDevices = [
    {device = "/dev/disk/by-uuid/dff97344-2eba-405b-996a-c073e1913ead";}
    {
      device = "/swap";
      size = 8 * 1024;
    }
  ];

  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
  hardware.cpu.intel.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;

  heywoodlh = {
    cloudflared = true;
    sshd.enable = true;
    intel-mac = true;
    nixos = {
      remote-desktop = {
        enable = true;
        user = "ops";
        uid = 1002;
        address = "100.67.47.0";
        headless.enable = true;
      };
      portmaster.enable = lib.mkForce false;
      scrutiny = {
        enable = true;
        port = 3050;
        ntfy = "ntfy://ntfy.barn-banana.ts.net/monitoring";
      };
    };
  };

  system.activationScripts.rebootPowerFailure.text = ''
    ${pkgs.pciutils}/bin/setpci -s 00:1f.0 0xa4.b=0
  '';

  security.sudo.extraConfig = ''
    heywoodlh  ALL=(ALL:ALL)    NOPASSWD:SETENV: ALL
  '';

  networking.firewall.interfaces.tailscale0.allowedTCPPorts = [
    8642
    9119
    3773
  ];

  systemd.targets = {
    sleep.enable = false;
    suspend.enable = false;
    hibernate.enable = false;
    hybrid-sleep.enable = false;
  };

  users.users.ops = {
    isNormalUser = true;
    uid = 1002;
    description = "Ops user";
    linger = true;
    extraGroups = [
      "adbusers"
      "networkmanager"
      "libvirtd"
    ];
    shell = pkgs.bashInteractive;
    homeMode = "755";
    openssh.authorizedKeys.keyFiles = [ssh-keys.outPath];
  };

  home-manager.users.ops = {
    home.stateVersion = "25.05";
    systemd.user.enable = true;
    home.activation.docker-rootless-context = ''
      if ! ${pkgs.docker-client}/bin/docker context ls | grep -iq rootless
      then
        ${pkgs.docker-client}/bin/docker context create rootless --docker "host=unix:///run/user/$(id -u)/docker.sock" &> /dev/null || true
        ${pkgs.docker-client}/bin/docker context use rootless
      fi
    '';
    heywoodlh.home = {
      paseo = {
        desktop = true;
        server = {
          enable = true;
          address = "100.67.47.0:6767";
          webui = true;
          hostnames = [
            "nixos-ops"
            "nixos-ops.barn-banana.ts.net"
          ];
        };
      };
      hermes = {
        enable = true;
        dashboard = {
          enable = true;
          address = "100.67.47.0";
        };
        remote = {
          enable = true;
          host = "nixos-ops.barn-banana.ts.net";
        };
        model = {
          default = "z-ai/glm-5.3-flash";
          provider = "OpenRouter";
        };
        environmentFiles = ["/home/ops/.hermes.env"];
        extraPlugins = [
          (pkgs.runCommand "claude-subscription-directsdk" {} ''
            cp -r ${pkgs.fetchFromGitHub {
              owner = "NousResearch";
              repo = "hermes-official-plugins";
              rev = "1e326ddd28ae261821d7714d106fe114999a0bba";
              hash = "sha256-9sxRw20aMkbGQXxoa5SEFGDDudwQq3GvGyKL8Yl0I/U=";
            }}/claude-subscription-directsdk $out
          '')
        ];
        settings.dashboard.public_url = "https://hermes.heywoodlh.io";
      };
      t3 = {
        enable = true;
        address = "100.67.47.0";
        hermes.enable = true;
        notifications.ntfy = {
          enable = true;
          url = "http://ntfy.barn-banana.ts.net/t3";
          clickTarget = "ios";
        };
      };
    };
  };
}
