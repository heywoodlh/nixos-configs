# Configuration loaded for all NixOS hosts
{ config, pkgs, determinate-nix, nixpkgs-stable, lib, nur, home-manager, ... }:

let
  system = pkgs.system;
  stdenv = pkgs.stdenv;
  stable-pkgs = import nixpkgs-stable {
    inherit system;
    config.allowUnfree = true;
  };
in {
  imports = [
    ./roles/virtualization/multiarch.nix
    determinate-nix.nixosModules.default
    home-manager.nixosModules.home-manager
  ];

  # Allow olm for gomuks until issues are resolved
  nixpkgs.config.permittedInsecurePackages = [
    "olm-3.2.16"
  ];

  nix = {
    package = pkgs.lib.mkForce determinate-nix.packages.${system}.default;
    extraOptions = ''
      extra-experimental-features = nix-command flakes
    '';
    settings = {
      auto-optimise-store = true;
      trusted-users = [
        "heywoodlh"
      ];
      extra-substituters = [
        "https://nix-community.cachix.org"
        "http://attic.barn-banana.ts.net/nixos"
      ];
      trusted-public-keys = [
        "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
        "nixos:pU2PdLt/QaDk8nec7lcy8DgsM96NTJ1bAOSs+jdoECc=" # attic
      ];
    };
  };

  # Stable, system-wide packages
  environment.systemPackages = with stable-pkgs; let
    nixPkg = determinate-nix.packages.${system}.default;
  in [
    gptfdisk
    (pkgs.writeShellScriptBin "nixos-switch" ''
      extra_args=""
      [[ -d /home/heywoodlh/opt/nixos-configs ]] || ${pkgs.git}/bin/git clone https://github.com/heywoodlh/nixos-configs /home/heywoodlh/opt/nixos-configs
      [[ -d /home/heywoodlh/opt/flakes ]] && extra_args="--override-input myFlakes /home/heywoodlh/opt/flakes"
      sudo ${nixPkg}/bin/nix run nixpkgs#nixos-rebuild -- switch --flake /home/heywoodlh/opt/nixos-configs#$(hostname) $extra_args $@
    '')
    mosh
  ];

  # Enable appimage
  programs.appimage = {
    enable = true;
    binfmt = true;
  };

  # Allow non-free applications to be installed
  nixpkgs.config.allowUnfree = true;

  home-manager = {
    useGlobalPkgs = true;
    extraSpecialArgs = {
      inherit nur;
      inherit determinate-nix;
    };
    users.heywoodlh = { ... }: {
      home.activation.docker-rootless-context = ''
        if ! ${pkgs.docker-client}/bin/docker context ls | grep -iq rootless
        then
          ${pkgs.docker-client}/bin/docker context create rootless --docker "host=unix:///run/user/1000/docker.sock" &> /dev/null || true
          ${pkgs.docker-client}/bin/docker context use rootless
        fi
      '';
    };
  };

  # Enable gnupg agent
  programs.gnupg.agent = {
    enable = true;
    pinentryPackage = pkgs.pinentry-curses;
  };

  programs.ssh.extraConfig = let
    altBuilder = if stdenv.isx86_64 then "ubuntu-arm64" else "";
  in ''
    # System-wide SSH config for nix builders
    Host mac-mini intel-mac-vm ${altBuilder}
      IdentityAgent /home/heywoodlh/.ssh/agent.sock
  '';

  # NixOS version
  system.stateVersion = "24.11";
}
