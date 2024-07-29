{ config, pkgs, lib, home-manager,
  nur, hyprland, nixpkgs-backports,
  nixpkgs-lts, myFlakes, flatpaks,
  ... }:

let
  system = pkgs.system;
  pkgs-backports = nixpkgs-backports.legacyPackages.${system};
  tmux = myFlakes.packages.${system}.tmux;
  battpop = pkgs.writeShellScriptBin "battpop" ''
    ${pkgs.acpi}/bin/acpi -b | ${pkgs.gnugrep}/bin/grep -Eo [0-9]+%
  '';
  timepop = pkgs.writeShellScriptBin "timepop" ''
    ${pkgs.coreutils}/bin/date "+%T"
  '';
  startFbterm = pkgs.writeShellScriptBin "start-fbterm" ''
    eval $(${pkgs.openssh}/bin/ssh-agent)
    export SSH_AUTH_SOCK=$SSH_AUTH_SOCK
    TERM=screen-256color exec /run/wrappers/bin/fbterm
  '';
  pbcopy = pkgs.writeShellScriptBin "pbcopy" ''
    stdin=$(${pkgs.coreutils}/bin/cat)
    ${pkgs.coreutils}/bin/printf "%s" "$stdin" | ${pkgs.tmux}/bin/tmux loadb -
  '';
  wifi = pkgs.writeShellScriptBin "wifi" ''
    ${pkgs.networkmanager}/bin/nmtui $@
  '';
in {
  imports = [
    home-manager.nixosModules.home-manager
    ./roles/desktop/user-icon.nix
    ./roles/virtualization/libvirt.nix
  ];

  # Use the systemd-boot EFI boot loader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  home-manager.useGlobalPkgs = true;

  nixpkgs.overlays = [
    # Import nur as nixpkgs.overlays
    nur.overlay
  ];

  boot = {
    kernelParams = [ "quiet" "splash" ];
    plymouth.enable = true;
    consoleLogLevel = 0;
    initrd.verbose = false;
  };

  nix.settings = {
    sandbox = true;
    auto-optimise-store = true;
    substituters = [
      "http://100.108.77.60:5000" # nix-nvidia
      "https://nix-community.cachix.org"
      "https://cache.nixos.org/"
    ];
    trusted-users = [
      "heywoodlh"
    ];
    trusted-public-keys = [
      "binarycache.heywoodlh.io:hT9E35rju+9L2CE/SDGUsytJtIZJfqVma7B7cp7Jym4=" # nix-nvidia
      "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
    ];
  };

  # Enable greetd+fbterm
  security.wrappers.fbterm = {
    owner = "root";
    group = "video";
    capabilities = "cap_sys_tty_config+ep";
    source = "${pkgs.fbterm}/bin/fbterm";
  };
  services.greetd = {
    enable = true;
    settings = {
      default_session = {
        command = "${pkgs.greetd.greetd}/bin/agreety --cmd ${startFbterm}/bin/start-fbterm";
      };
    };
  };
  # Networking
  networking = {
    nftables.enable = true;
    networkmanager.enable = true;
  };

  # Enable Tailscale
  services.tailscale.enable = true;

  # Configure keymap in X11
  services.xserver.xkb = {
    layout = "us";
    variant = "";
  };

  # Android debugging
  programs.adb.enable = true;

  # iPhone usb support
  services.usbmuxd.enable = true;

  # Seahorse (Gnome Keyring)
  programs.seahorse.enable = true;

  services = {
    logind = {
      extraConfig = "RuntimeDirectorySize=10G";
    };
    syncthing = {
      enable = true;
      user = "heywoodlh";
      dataDir = "/home/heywoodlh/Sync";
      configDir = "/home/heywoodlh/.config/syncthing";
    };
  };

  # Virtualization
  virtualisation = {
    docker.rootless = {
      package = pkgs-backports.docker;
      enable = true;
      setSocketVariable = true;
    };
  };
  users.extraGroups.vboxusers.members = [ "heywoodlh" ];
  users.extraGroups.disk.members = [ "heywoodlh" ];
  users.extraGroups.video.members = [ "heywoodlh" ];

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;
  # Allow x86 packages to be installed on aarch64
  nixpkgs.config.allowUnsupportedSystem = true;

  networking.firewall = {
    enable = true;
    checkReversePath = "loose";
  };

  fonts.packages = with pkgs; [
    (nerdfonts.override { fonts = [ "Hack" "DroidSansMono" "Iosevka" "JetBrainsMono" ]; })
  ];

  users.users.heywoodlh = {
    isNormalUser = true;
    description = "Spencer Heywood";
    extraGroups = [ "networkmanager" "wheel" "adbusers" ];
    shell = "${tmux}/bin/tmux";
    homeMode = "755";
  };

  environment.homeBinInPath = true;
  environment.shells = [
    pkgs.bashInteractive
  ];

  environment.systemPackages = [
    pkgs.busybox
    pkgs.libimobiledevice # for iPhone
    pkgs.idevicerestore # for iPhone
    pkgs.ifuse
    pkgs.usbutils
    pkgs.fbterm
    pkgs.browsh
    pkgs.firefox # for browsh
    pkgs.w3m
    myFlakes.packages.${system}.tmux
    myFlakes.packages.${system}.vim
    battpop
    timepop
    pbcopy
    wifi
  ];

  # Disable wait-online service for Network Manager
  systemd.services.NetworkManager-wait-online.enable = false;

  # Home-manager configs
  home-manager = {
    extraSpecialArgs = {
      inherit myFlakes;
      inherit nixpkgs-lts;
    };
    users.heywoodlh = { ... }: {
      imports = [
        ../home/linux.nix
        flatpaks.homeManagerModules.default
      ];
      home.packages = [
        myFlakes.packages.${system}.git
      ];
      home.file."bin/nixos-switch" = {
        enable = true;
        executable = true;
        text = ''
          #!/usr/bin/env bash
          [[ -d ~/opt/nixos-configs ]] || git clone https://github.com/heywoodlh/nixos-configs
          git -C ~/opt/nixos-configs pull origin master
          /run/wrappers/bin/sudo nixos-rebuild switch --flake ~/opt/nixos-configs#$(hostname) --impure $@
        '';
      };
      home.file.".config/fbterm/fbtermrc" = {
        enable = true;
        text = ''
          font-names=JetBrainsMono Nerd Font
          font-size=14
          #font-width=
          #font-height=

          # terminal palette consists of 256 colors (0-255)
          # 0 = black, 1 = red, 2 = green, 3 = brown, 4 = blue, 5 = magenta, 6 = cyan, 7 = white
          # 8-15 are brighter versions of 0-7
          # 16-231 is 6x6x6 color cube
          # 232-255 is grayscale
          # Nord theme, from https://github.com/mbadolato/iTerm2-Color-Schemes/blob/master/kitty/nord.conf
          color-0=3B4252
          color-1=BF616A
          color-2=A3BE8C
          color-3=EBCB8B
          color-4=81A1C1
          color-5=B48EAD
          color-6=88C0D0
          color-7=E5E9F0
          color-8=4C566A
          color-9=BF616A
          color-10=A3BE8C
          color-11=EBCB8B
          color-12=81A1C1
          color-13=B48EAD
          color-14=8FBCBB
          color-15=ECEFF4
          color-foreground=D8DEE9
          color-background=2E3440

          history-lines=0
          text-encodings=

          # cursor shape: 0 = underline, 1 = block
          # cursor flash interval in milliseconds, 0 means disable flashing
          cursor-shape=1
          cursor-interval=500

          # additional ascii chars considered as part of a word while auto-selecting text, except ' ', 0-9, a-z, A-Z
          word-chars=._-

          # change the clockwise orientation angle of screen display
          # available values: 0 = 0 degree, 1 = 90 degrees, 2 = 180 degrees, 3 = 270 degrees
          screen-rotate=0

          # specify the favorite input method program to run
          input-method=
        '';
      };
    };
  };

  programs.nix-index.enable = true;
  programs.command-not-found.enable = false;

  # Automatically garbage collect
  nix.gc = {
    automatic = true;
    dates = "daily";
    options = "--delete-older-than 7d";
  };
}
