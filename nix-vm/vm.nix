{ config, pkgs, ... }:

let
  unstable = import <nixos-unstable> { config = { allowUnfree = true; }; };
in {
  imports =
    [ 
      <home-manager/nixos> 
    ];

  # Enable networking
  networking.networkmanager.enable = true;

  # Select internationalisation properties.
  i18n.defaultLocale = "en_US.utf8";

  # Configure keymap in X11
  services.xserver = {
    layout = "us";
    xkbVariant = "";
  };

  # Enable CUPS to print documents.
  services.printing.enable = true;

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.heywoodlh = {
    isNormalUser = true;
    description = "Spencer Heywood";
    extraGroups = [ "networkmanager" "wheel" ];
    shell = pkgs.powershell;
    openssh.authorizedKeys.keys = [ "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQC1aOhZI4Uo8jpPnmJe2aalB/HT2n42bo270IVxyRLURrmNrro8y/MEDD55GU9AVieVu2P+W4xBlWYaDJjSngWAh+zV6hrEhCSeGXiRnIZ+dpOBU5gcOFJxOpvSVawmqJFTjFUAdkHSLYuf9dtbasDkbxyyb/8Hh9jFjT0bisSRKi/SEmkh5m4nU7ySa1ltb6htUgQ/Y71Fi09BJWhktiT9HrtL4Gs0wzch9biaH/AFGbRNEnAZgQMAL/zS08IfevR7sYoHyjwVSwWVmA4TOhsm+auu9zPV4WgrnY2BNy+H9tF74AP6s+sf19uQG/2qVS3xcrvw2VhQCwPGHpv0o0tGLaCQBwjmqhbrBzVO4Hy1d/vskxe7Zr6IEEbQTLXTsYo6/yiEXOTzOvN7/V/zzdZkeUdRFGxqIu3EABH5wxNYOMwXNlOjnsxsE5VTovkMeIb+No1itaj1xGXuKBKJzRzKJ9pPLxtiaOimXxG4LYg3Ef50V6JzwT7UxY4DiS3JBUxQSxQ5CxifKRN/pCzUMlsdm+yIoXhy57r6JjFtnzet2Ytz12Vp8vRx6ZNH7upMxMBxmWH0sG7hf7fLjmVuurcL7pIB5U7a5rwUhfTjLUAJSg+DDvaOHyhBUsZp7wRxwoJuctvfxoxSkQtNlimWOwuPQgmNIfjjPQUKwM3j95RZiw== tyranny" "ecdsa-sha2-nistp256 AAAAE2VjZHNhLXNoYTItbmlzdHAyNTYAAAAIbmlzdHAyNTYAAABBBPjnAIPI3ypyi8qn8QNlh8jlVxtaZYKRxXjJ1CDWj+Luuv3cbdsmM8V2SeRToeJHCV/qROa8nEnrnFrUqQ3+9qE= chg-mac@secretive.C02GC0NYMD6R.local" ];
    packages = with pkgs; [
      aerc
      ansible
      automake
      awscli2
      bind
      bitwarden-cli
      coreutils
      curl
      dante
      docker-compose
      file
      fzf
      gcc
      git
      gitleaks
      github-cli
      glib.dev
      glow
      gnumake
      gnupg
      go
      gotify-cli
      htop
      inotify-tools
      jq
      k9s
      keyutils
      kitty
      kubectl
      lima
      lsof
      lefthook
      mosh
      neofetch
      nerdfonts
      nim
      nordic
      olm
      pass 
      (pass.withExtensions (ext: with ext; 
      [ 
        pass-otp 
      ])) 
      peru
      powershell
      python39
      python39Packages.matrix-nio
      (python3.withPackages (ps: with ps; 
      [
        cryptography
        pip
        python-olm
        websocket-client
        "pyOpenSSL"
        webcolors
        atomicwrites
        attrs
        "logbook"
        pygments
        matrix-nio
        "matrix-nio[e2e]"
        aiohttp
        python-magic
        requests
      ]))
      qemu-utils
      qrencode
      rofi
      screen
      scrot
      tcpdump
      tmux
      vim
      vultr-cli
      w3m
      weechat
      weechatScripts.weechat-matrix
      wireguard-tools
    ];
  };

  services = {
    syncthing = {
      enable = true;
      user = "heywoodlh";
      dataDir = "/home/heywoodlh/Sync";
      configDir = "/home/heywoodlh/.config/syncthing";
    };
    unclutter = {
      enable = true;
      timeout = 10;
    };
  };

  virtualisation = {
    docker.rootless = {
      enable = true;
    };
  };

  # So that `nix search` works
  nix.extraOptions = '' 
    extra-experimental-features = nix-command flakes
  '';

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  networking.firewall = {
    enable = true;
    allowedTCPPorts = [ 22 ];
    allowedUDPPorts = [ 51820 ];
    # For Mosh
    allowedUDPPortRanges = [
      { from = 60000; to = 61000; }
    ];
  };

  environment.systemPackages = with pkgs; [
  #  vim
  ];

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  # programs.gnupg.agent = {
  #   enable = true;
  #   enableSSHSupport = true;
  # };

  # List services that you want to enable:

  # Enable the OpenSSH daemon.
  services.openssh.enable = true;
  services.openssh.sftpServerExecutable = "internal-sftp";

  system.stateVersion = "22.11";
}
