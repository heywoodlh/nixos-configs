{ config, pkgs, ... }:

{
  imports = [
    ./hardware-configuration.nix
    ../../roles/steam-deck.nix
    ../../desktop.nix
  ];


  # Use the systemd-boot EFI boot loader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  networking.hostName = "nix-steam-deck";

  time.timeZone = "America/Denver";

  i18n.defaultLocale = "en_US.utf8";

  #systemd.services.wireguard = {
  #  enable = true;
  #  description = "Wireguard on Demand Service";
  #  serviceConfig = {
  #    ExecStart = "/opt/scripts/wireguard.sh";
  #  };
  #  wantedBy = [ "multi-user.target" ];
  #};

  users.users.heywoodlh = {
    openssh.authorizedKeys.keys = [
      "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQC1aOhZI4Uo8jpPnmJe2aalB/HT2n42bo270IVxyRLURrmNrro8y/MEDD55GU9AVieVu2P+W4xBlWYaDJjSngWAh+zV6hrEhCSeGXiRnIZ+dpOBU5gcOFJxOpvSVawmqJFTjFUAdkHSLYuf9dtbasDkbxyyb/8Hh9jFjT0bisSRKi/SEmkh5m4nU7ySa1ltb6htUgQ/Y71Fi09BJWhktiT9HrtL4Gs0wzch9biaH/AFGbRNEnAZgQMAL/zS08IfevR7sYoHyjwVSwWVmA4TOhsm+auu9zPV4WgrnY2BNy+H9tF74AP6s+sf19uQG/2qVS3xcrvw2VhQCwPGHpv0o0tGLaCQBwjmqhbrBzVO4Hy1d/vskxe7Zr6IEEbQTLXTsYo6/yiEXOTzOvN7/V/zzdZkeUdRFGxqIu3EABH5wxNYOMwXNlOjnsxsE5VTovkMeIb+No1itaj1xGXuKBKJzRzKJ9pPLxtiaOimXxG4LYg3Ef50V6JzwT7UxY4DiS3JBUxQSxQ5CxifKRN/pCzUMlsdm+yIoXhy57r6JjFtnzet2Ytz12Vp8vRx6ZNH7upMxMBxmWH0sG7hf7fLjmVuurcL7pIB5U7a5rwUhfTjLUAJSg+DDvaOHyhBUsZp7wRxwoJuctvfxoxSkQtNlimWOwuPQgmNIfjjPQUKwM3j95RZiw== tyranny"
      "ecdsa-sha2-nistp256 AAAAE2VjZHNhLXNoYTItbmlzdHAyNTYAAAAIbmlzdHAyNTYAAABBBPjnAIPI3ypyi8qn8QNlh8jlVxtaZYKRxXjJ1CDWj+Luuv3cbdsmM8V2SeRToeJHCV/qROa8nEnrnFrUqQ3+9qE= chg-mac@secretive.C02GC0NYMD6R.local"
      "ecdsa-sha2-nistp256 AAAAE2VjZHNhLXNoYTItbmlzdHAyNTYAAAAIbmlzdHAyNTYAAABBBBmGLMTS02Ck2EkTTWxGkLp3B+l/6uvxMSlwrQ7gBTojZYnZab4AncwyHyFA08vGXCm/jKOMsyqmNHXQZkmZ4QA= nix-macbook-air@secretive.nix-macbook-air.local"
      "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQCYn+7oSNHXN3qqDDidw42Vv7fDS0iEpYqaa0wCXRPBlfWAnD81f6dxj/QPGfZtxpl9jvk7nAKpE7RVUvQiJzUC2VM3Bw/4ucT+xliEHo3oesMQQa1AT70VPTbP5PdU7oUpgQWLq39j9XHno2YPJ/WWtuOl/UTjY6IDokkAmNmvft/jqqkiwSkGMmw68qrLFEM7+rNwJV5cXKvvpB6Gqc7qnbJmk1TZ1MRGW5eLjP9ofDqiyoLbnTm7Dw3iHn40GgTcnv5CWGpa0vrKnnLEGrgRB7kR/pyvfsjapkHz0PDvuinQov+MgJfV8B8PHdPC94dsS0DEWJplxhYojtsYa1VZy5zTEMNWICz1QG1yKHN1JQtpbEreHG6DVYvqwnKvK/XN5yiEeiamhD2oKnSh36PexIR0h0AAPO29Ln+anqpRlqJ0nET2CNS04e0vpV4VDJrG6BnyGUQ6CCo7THSq97F4Ne0nY9fpYu5WTFTCh1tTm+nSey0fP/xk22oINl/41VTI/Vk5pNQuuhHUvQupJHw9cD74aKzRddwvgfuAQjPlEuxxsqgFTltTiPF6lZQNeoMIc1OMCRsnl1xNqIepnb7Q5O1CGq+BqtOWh3G4/SPQI5ZUIkOAZegsnPpGWYMrRd7s6LJn5LrBYaY6IvRxmpGOig3tjOUy3fqk7coyTeJXmQ== bitwarden"
    ];
  };

  networking.firewall = {
    enable = true;
    allowedTCPPorts = [ 22 ];
    allowedUDPPorts = [ 51820 ];
    # For Mosh
    allowedUDPPortRanges = [
      { from = 60000; to = 61000; }
    ];
  };

  services.syncthing.guiAddress = "0.0.0.0:8384";

  services.openssh.enable = true;
  services.openssh.sftpServerExecutable = "internal-sftp";

  virtualisation = {
    waydroid.enable = true;
    lxd.enable = true;
  };

  fileSystems = {
    # SD card
    "/sdcard" = {
      device = "/dev/disk/by-uuid/00b4681f-37f2-4fc7-81ec-a8a53e761d5b";
      fsType = "ext4";
      # It's okay if it's missing, automounted on access
      options = [ "nofail" "x-systemd.automount" ];
    };
  };

  home-manager.users.heywoodlh.home.packages = with pkgs; [
    pkgs.moonlight-qt
  ];

  programs.steam.enable = true;

  # Use a remote machine for builds
  nix = {
    distributedBuilds = true;
    buildMachines = [
      {
        hostName = "nix-nvidia.tailscale";
        system = "x86_64-linux";
        protocol = "ssh";
      }
    ];
  };
  system.stateVersion = "22.11";
}

