{ config, pkgs, lib, home-manager,
  nur, hyprland, nixpkgs-backports,
  nixpkgs-lts, myFlakes,
  ... }:

let
  system = pkgs.system;
  pkgs-backports = nixpkgs-backports.legacyPackages.${system};
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
  #pbcopy = pkgs.writeShellScriptBin "pbcopy" ''
  #  stdin=$(${pkgs.coreutils}/bin/cat)
  #  ${pkgs.coreutils}/bin/printf "%s" "$stdin" | ${pkgs.tmux}/bin/tmux loadb -
  #'';
  wifi = pkgs.writeShellScriptBin "wifi" ''
    ${pkgs.networkmanager}/bin/nmtui $@
  '';
in {
  imports = [
    ./base.nix
    ./roles/virtualization/libvirt.nix
  ];

  nixpkgs.overlays = [
    # Import nur as nixpkgs.overlays
    nur.overlays.default
  ];

  boot = {
    kernelParams = [ "quiet" "splash" ];
    plymouth.enable = true;
    consoleLogLevel = 0;
    initrd.verbose = false;
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

  fonts.packages = with pkgs.nerd-fonts; [
    jetbrains-mono
  ];

  users.users.heywoodlh = {
    isNormalUser = true;
    description = "Spencer Heywood";
    extraGroups = [ "networkmanager" "wheel" "adbusers" ];
    homeMode = "755";
    shell = pkgs.bashInteractive;
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
    #pbcopy
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
      ];
      home.packages = [
        myFlakes.packages.${system}.git
      ];
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
