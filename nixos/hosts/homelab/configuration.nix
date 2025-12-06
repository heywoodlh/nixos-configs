{ config, pkgs, lib, ... }:

let
  ollama_pull = pkgs.writeShellScriptBin "ollama-pull" ''
    models=("llama3:8b" "llama3.1:8b" "deepseek-coder:6.7b" "mistral:7b" "gemma3:4b" "qwen3:8b")
    # Pull existing models
    ${pkgs.ollama}/bin/ollama list | awk '{print $1}' | xargs -I {} ${pkgs.ollama}/bin/ollama pull "{}"
    for model in "''${models[@]}"
    do
      ${pkgs.ollama}/bin/ollama pull "''${model}"
    done
  '';
in {
  imports =
  [ # Include the results of the hardware scan.
    ./hardware-configuration.nix
    ../../roles/monitoring/syslog-ng/server.nix
    ../../roles/monitoring/syslog-ng/client.nix
    ../../roles/gaming/minecraft-bedrock.nix
    ../../roles/containers/k3s-server.nix
    ../../roles/monitoring/osquery.nix
    ../../roles/nixos/cache.nix
    ../../roles/home-automation/homebridge.nix
    ../../roles/monitoring/ntfy-signal.nix
    ../../roles/nixos/cache-populator.nix
    ../../roles/media/plex.nix
    ../../roles/media/youtube.nix
    ../../roles/monitoring/iperf.nix
    ../../roles/storage/nfs-media.nix
    ../../roles/remote-access/cloudflared.nix
    ../../roles/remote-access/wol.nix
    ../../roles/security/hexstrike-ai.nix
  ];

  # Bootloader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.loader.efi.efiSysMountPoint = "/boot/efi";

  # Enable networking
  networking.networkmanager.enable = true;
  networking.hostName = "homelab"; # Define your hostname

  # Set your time zone.
  time.timeZone = "America/Denver";

  boot.kernelPackages = pkgs.linuxPackages_xanmod_stable;

  # Enable ZFS
  boot.extraModulePackages = [ pkgs.linuxKernel.packages.linux_xanmod_stable.zfs_unstable ];
  boot.zfs.package = pkgs.zfs_unstable;
  boot.supportedFilesystems = [ "zfs" ];
  systemd.services.zfs-mount.enable = false; # Disable systemd service for ZFS mount, use Filesystems option instead
  networking.hostId = "fd838b2e"; # Set a unique host ID for ZFS

  nixpkgs.config.allowUnfree = true;
  # Make sure opengl is enabled
  hardware.graphics = {
    enable = true;
    enable32Bit = true;
  };

  fileSystems."/media/data-ssd" ={
    device = "/dev/disk/by-uuid/ad1b8750-51fb-4270-b0c2-739276f30a95";
    fsType = "ext4";
  };

  # Prevent system from sleeping (for XRDP to work)
  systemd.targets.sleep.enable = false;
  systemd.targets.suspend.enable = false;
  systemd.targets.hibernate.enable = false;
  systemd.targets.hybrid-sleep.enable = false;

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

  virtualisation.docker.enable = true;
  environment.systemPackages = with pkgs; [
    docker
    ollama_pull
    nfdump
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
      "3 4 * * 7      root    rm -rf /var/lib/cni/networks/cbr0/"
      "0 0 * * *      root    ${ollama_pull}/bin/ollama-pull"
      "5 4 * * 7      root    shutdown -r now"
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
    "/media/data-ssd/ollama"
    "/opt/syncthing/mac-mini-vm"
    "/opt/syncthing/clone-hero-songs"
    "/opt/syncthing/opt/nixpkgs"
    "/opt/syncthing/gamma"
    "/opt/syncthing/anomaly"
  ];

  # Resolve too many open files error
  # https://discourse.nixos.org/t/unable-to-fix-too-many-open-files-error/27094/7
  # https://askubuntu.com/a/1451118
  systemd.settings.Manager.DefaultLimitNOFILE = 2048; # defaults to 1024 if unset
  boot.kernel.sysctl = {
    "fs.inotify.max_user_instances" = 1024;
  };

  # Route mullvad through Tailscale
  services.tailscale.extraSetFlags = [
    "--advertise-routes=10.64.0.1/32"
    "--accept-dns"
    "--stateful-filtering"
  ];

  # Hack to enable i915 driver for Intel GPU (for Kubernetes)
  services.xserver.videoDrivers = [
    "i915"
  ];

  # Do not start k3s is media drives fail
  systemd.services.k3s = let
    mediaMounts = [
      "media-data\\x2dssd.mount"
      "media-home\\x2dmedia-disk1.mount"
      "media-home\\x2dmedia-disk2.mount"
      "media-home\\x2dmedia-disk3.mount"
    ];
  in {
    after = mediaMounts;
    requires = mediaMounts;
  };
}
