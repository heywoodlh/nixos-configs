{ config, pkgs, lib, ... }:

{
  imports =
  [ # Include the results of the hardware scan.
    ./hardware-configuration.nix
    ../../server.nix
    ../../roles/virtualization/libvirt.nix
    ../../roles/monitoring/syslog-ng/server.nix
    ../../roles/monitoring/syslog-ng/client.nix
    ../../roles/gaming/minecraft-bedrock.nix
    #../../roles/monitoring/graylog.nix
    ../../roles/containers/k3s-server.nix
    ../../roles/security/fleetdm.nix
    ../../roles/monitoring/osqueryd.nix
    ../../roles/nixos/cache.nix
    #../../roles/remote-access/wireguard-server.nix
    ../../roles/home-automation/homebridge.nix
    ../../roles/monitoring/ntfy-signal.nix
    ../../roles/nixos/cache-populator.nix
    ../../roles/media/plex.nix
    ../../roles/media/youtube.nix
    ../../roles/monitoring/iperf.nix
    ../../roles/storage/nfs-media.nix
    ../../roles/remote-access/cloudflared.nix
    ../../roles/remote-access/wol.nix
    #../../roles/dev/vscode.nix # many things don't work with non-standard Nix paths
  ];

  # Bootloader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.loader.efi.efiSysMountPoint = "/boot/efi";

  # Enable networking
  networking.networkmanager.enable = true;
  networking.hostName = "nix-nvidia"; # Define your hostname

  # Set your time zone.
  time.timeZone = "America/Denver";

  # Select internationalisation properties.
  i18n.defaultLocale = "en_US.utf8";

  # Enable Nvidia driver
  boot.kernelPackages = lib.mkForce pkgs.linuxKernel.packages.linux_xanmod_stable;
  nixpkgs.config.allowUnfree = true;
  # Make sure opengl is enabled
  hardware.graphics = {
    enable = true;
    enable32Bit = true;
  };

  # Tell Xorg to use the nvidia driver (also valid for Wayland)
  services.xserver.videoDrivers = ["nvidia"];

  hardware.nvidia = {
    modesetting.enable = true;
    open = false;
    nvidiaSettings = true;
    package = pkgs.linuxKernel.packages.linux_xanmod_stable.nvidia_x11;
  };

  # This drive seems to have issues
  #fileSystems."/media/data-ssd" ={
  #  device = "/dev/disk/by-uuid/4445dc2a-ecab-4401-ac4c-b2c78a53644b";
  #  fsType = "ext4";
  #  options = [ "rw" "uid=1000" "rw" "nofail" "relatime" "x-systemd.mount-timeout=5min" ];
  #};

  # Prevent system from sleeping (for XRDP to work)
  systemd.targets.sleep.enable = false;
  systemd.targets.suspend.enable = false;
  systemd.targets.hibernate.enable = false;
  systemd.targets.hybrid-sleep.enable = false;

  # K8s cluster
  services.k3s = {
    role = "server";
    extraFlags = toString [
      "--tls-san=nix-nvidia"
      "--tls-san=100.108.77.60"
    ];
  };

  # Enable mullvad wireguard
  networking.wg-quick.interfaces = {
    mullvad = {
      address = [ "10.73.97.192/32" ];
      privateKeyFile = "/root/wgkey";
      listenPort = 51820;

      peers = [
        {
          publicKey = "sSoow0tFfqSrZIUhFRaGsTvwQsUTe33RA/9PLn93Cno=";
          allowedIPs = [ "10.64.0.1/24" ];
          endpoint = "69.4.234.9:51820";
          persistentKeepalive = 25;
        }
      ];
    };
  };

  # Forward port 1080 to tailscale interface to mullvad
  networking = {
    nftables.enable = lib.mkForce false;
    firewall = {
      enable = true;
      allowedUDPPorts = [
        9995
      ];
      allowedTCPPorts = [
        1080
        443
        3389
        5900
      ];
      extraCommands = "iptables -t nat -A POSTROUTING -d 10.64.0.1 -p tcp -m tcp --dport 1080 -j MASQUERADE";
    };
    nat = {
      enable = true;
      internalInterfaces = [ "mullvad" ];
      externalInterface = "tailscale0";
      forwardPorts = [
        {
          sourcePort = 1080;
          proto = "tcp";
          destination = "10.64.0.1:1080";
        }
      ];
    };
  };

  hardware.bluetooth.enable = true;
  hardware.bluetooth.powerOnBoot = true;

  # Nvidia container settings
  virtualisation.docker.enable = true;
  hardware.nvidia-container-toolkit = {
    enable =  true;
    mount-nvidia-executables = true;
  };
  environment.systemPackages = with pkgs; [
    docker
    nfdump
    nvidia-container-toolkit
    runc
  ];

  services = {
    syncthing = {
      enable = true;
      user = "heywoodlh";
      dataDir = "/home/heywoodlh/Sync";
      configDir = "/home/heywoodlh/.config/syncthing";
    };
  };
  # allow building ARM64 things
  boot.binfmt.emulatedSystems = [ "aarch64-linux" ];

  services.cron = {
    enable = true;
    systemCronJobs = [
      "5 4 * * *      root    shutdown -r now"
    ];
  };

  # Exclude Documents folder in Tarsnap
  services.tarsnap.archives.nixos.excludes = [
    "/home/heywoodlh/Documents"
    "/opt/fauxpilot"
    "/opt/graylog"
    "/opt/nfcapd"
    "/opt/open-webui"
    "/opt/protonmail-bridge"
    "/opt/serge"
    "/opt/ollama/models"
  ];

  # Resolve too many open files error
  # https://discourse.nixos.org/t/unable-to-fix-too-many-open-files-error/27094/7
  # https://askubuntu.com/a/1451118
  systemd.extraConfig = "DefaultLimitNOFILE=2048"; # defaults to 1024 if unset
  boot.kernel.sysctl = {
    "fs.inotify.max_user_instances" = 1024;
  };

  # Enable CI/CD
  services.comin.enable = true;

  # Route mullvad through Tailscale
  services.tailscale.extraSetFlags = [
    "--advertise-routes=10.64.0.1/32"
  ];

  systemd.services.ollama.serviceConfig.Restart = lib.mkForce "always";

  users = {
    groups.ollama = {
      name = "ollama";
      gid = 900;
    };
    users.ollama = {
      isSystemUser = true;
      uid = 900;
      group = "ollama";
      home  = "/opt/ollama";
      description  = "Ollama user";
    };
  };

  services.ollama = {
    enable = true;
    host = "100.108.77.60";
    acceleration = "cuda";
    home = "/opt/ollama";
    models = "/opt/ollama/models";
    loadModels = [
      "deepseek-r1:8b"
      "codellama:7b"
      "deepseek-coder:6.7b"
      "qwen2-math:7b"
      "llama3:8b"
    ];
  };
}
