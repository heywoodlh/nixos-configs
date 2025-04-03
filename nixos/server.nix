{ config, pkgs,
  home-manager, nur,
  myFlakes,
  nixpkgs-backports,
  comin,
  nixpkgs-wazuh-agent,
  ... }:

let
  system = pkgs.system;
  pkgs-backports = nixpkgs-backports.legacyPackages.${system};
  myVim = myFlakes.packages.${system}.vim;
  myGit = myFlakes.packages.${system}.git;
  wazuhPkg = pkgs.callPackage ./pkgs/wazuh.nix {};
in {
  imports = [
    comin.nixosModules.comin
    ./base.nix
    ./roles/remote-access/sshd.nix
    ./roles/security/sshd-monitor.nix
    ./roles/tailscale.nix
    ./roles/monitoring/syslog-ng/client.nix
    ./roles/monitoring/node-exporter.nix
    ./roles/monitoring/osqueryd.nix
    ./roles/backups/tarsnap.nix
    "${nixpkgs-wazuh-agent}/nixos/modules/services/security/wazuh/wazuh.nix"
  ];

  nixpkgs.overlays = [
    # Import nur as nixpkgs.overlays
    nur.overlays.default
  ];

  # Packages to install on entire system
  environment.systemPackages = [
    pkgs.ansible
    pkgs.autoPatchelfHook
    pkgs.bind
    pkgs.btrfs-progs
    pkgs.busybox
    pkgs.croc
    pkgs.file
    pkgs.gcc
    myGit
    pkgs.gnumake
    pkgs.gnupg
    pkgs.gptfdisk
    pkgs.htop
    pkgs.jq
    pkgs.lsof
    pkgs.nix-index
    pkgs.patchelf
    pkgs.python3
    pkgs.unzip
    pkgs.wireguard-tools
    pkgs.zsh
    myVim
  ];

  # Wazuh configuration
  #services.wazuh = {
  #  package = wazuhPkg;
  #  agent = {
  #    enable = true;
  #    managerIP = "wazuh.barn-banana.ts.net";
  #  };
  #};

  # Enable Docker
  virtualisation = {
    docker = {
      enable = true;
      package = pkgs-backports.docker;
    };
    docker.rootless = {
      package = pkgs-backports.docker;
      enable = true;
      setSocketVariable = true;
    };
  };

  # Define user
  users.users.heywoodlh = {
    isNormalUser = true;
    uid = 1000;
    home = "/home/heywoodlh";
    description = "Spencer Heywood";
    extraGroups = [ "wheel" ];
    shell = pkgs.bashInteractive;
  };

  programs.fish = {
    enable = true;
    interactiveShellInit = ''
      if not ${pkgs.ps}/bin/ps -fjH -u $USER | ${pkgs.gnugrep}/bin/grep ssh-agent | ${pkgs.gnugrep}/bin/grep -q "$HOME/.ssh/agent.sock" &> /dev/null
        mkdir -p $HOME/.ssh
        rm -f $HOME/.ssh/agent.sock &> /dev/null
        eval (${pkgs.openssh}/bin/ssh-agent -t 4h -c -a "$HOME/.ssh/agent.sock") &> /dev/null || true
      end
    '';
  };

  # Set home-manager configs for username
  home-manager = {
    extraSpecialArgs = {
      inherit myFlakes;
    };
    users.heywoodlh = { ... }: {
      imports = [
        ../home/linux.nix
      ];
    };
  };

  # Allow heywoodlh to run sudo commands without password
  security.sudo.wheelNeedsPassword = false;

  # Disable wait-online service for Network Manager
  systemd.services.NetworkManager-wait-online.enable = false;

  # Stage CI/CD
  services.comin = {
    #enable = true; # Assume opt-in
    remotes = [{
      name = "origin";
      url = "https://github.com/heywoodlh/nixos-configs.git";
      branches.main.name = "master";
      poller.period = 86400; # Auto-update every 24 hours
    }];
  };

  nix.gc = {
    automatic = true;
    dates = "daily";
    options = "--delete-older-than 7d";
  };
}
