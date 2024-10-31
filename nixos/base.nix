# Configuration loaded for all NixOS hosts
{ config, pkgs, nixpkgs-stable, lib, stdenv, nur, nixpkgs-wazuh-agent, ... }:

let
  system = pkgs.system;
  wazuhPkg = pkgs.callPackage ./pkgs/wazuh.nix {};
  stable-pkgs = import nixpkgs-stable {
    inherit system;
    config.allowUnfree = true;
  };
in {
  imports = [
    ./roles/virtualization/multiarch.nix
    "${nixpkgs-wazuh-agent}/nixos/modules/services/security/wazuh/wazuh.nix"
  ];

  # Allow olm for gomuks until issues are resolved
  nixpkgs.config.permittedInsecurePackages = [
    "olm-3.2.16"
  ];

  # Enable flakes
  nix.extraOptions = ''
    extra-experimental-features = nix-command flakes
  '';
  # Automatically optimize store for better storage
  nix.settings = {
    auto-optimise-store = true;
    trusted-users = [
      "heywoodlh"
    ];
    substituters = [
      "https://nix-community.cachix.org"
      "http://attic.barn-banana.ts.net/nixos"
      "https://heywoodlh-helix.cachix.org"
    ];
    trusted-public-keys = [
      "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
      "nixos:ZffGHlb0Ng3oXu8cLT9msyOB/datC4r+/K9nImONIec=" # attic
      "heywoodlh-helix.cachix.org-1:qHDV95nI/wX9pidAukzMzgeok1415rgjMAXinDsbb7M="
    ];
  };

  # Stable, system-wide packages
  environment.systemPackages = with stable-pkgs; [
    gptfdisk
    (pkgs.writeShellScriptBin "nixos-switch" ''
    [[ -d /home/heywoodlh/opt/nixos-configs ]] || ${pkgs.git}/bin/git clone https://github.com/heywoodlh/nixos-configs /home/heywoodlh/opt/nixos-configs
    sudo chown -R heywoodlh /home/heywoodlh/opt/nixos-configs
    sudo ${pkgs.nixos-rebuild}/bin/nixos-rebuild switch --flake /home/heywoodlh/opt/nixos-configs#$(hostname) $@
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

  # Wazuh configuration
  services.wazuh = {
    package = wazuhPkg;
    agent = {
      enable = true;
      managerIP = "wazuh.barn-banana.ts.net";
    };
  };

  # Enable gnupg agent
  programs.gnupg.agent = {
    enable = true;
    pinentryPackage = pkgs.pinentry-curses;
  };

  # NixOS version
  system.stateVersion = "24.11";
}
