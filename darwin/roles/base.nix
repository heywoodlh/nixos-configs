{ config, pkgs, determinate-nix, home-manager, myFlakes, nur, ts-warp-nixpkgs, qutebrowser, ghostty, attic, iamb-home-manager, hexstrike-ai, ... }:

let
  system = pkgs.system;
  nixPkg = determinate-nix.packages.${system}.default;
in {
  # Define user settings
  users.users.heywoodlh = import ../roles/user.nix {
    inherit config;
    inherit pkgs;
  };
  system.primaryUser = "heywoodlh";

  # Allow olm for gomuks until issues are resolved
  nixpkgs = {
    hostPlatform.system = "aarch64-darwin";
    config.permittedInsecurePackages = [
      "olm-3.2.16"
    ];
  };

  # Home-Manager config
  home-manager = {
    extraSpecialArgs = {
      inherit myFlakes;
      inherit ts-warp-nixpkgs;
      inherit qutebrowser;
      inherit ghostty;
      inherit nur;
      inherit determinate-nix;
      inherit attic;
      inherit iamb-home-manager;
      inherit hexstrike-ai;
    };
    # Set home-manager configs for heywoodlh
    users.heywoodlh = { ... }: {
      imports = [
        ../../home/darwin.nix
      ];
    };
  };

  environment.etc."ssh/ssh_config".text = ''
    Host *
      SendEnv LANG LC_*
    IdentityAgent /Users/heywoodlh/Library/Group\ Containers/2BUA8C4S2C.com.1password/t/agent.sock
    Include /etc/ssh/ssh_config.d/*
  '';

  nix = {
    package = pkgs.lib.mkForce nixPkg;
    settings = {
      extra-substituters = [
        "https://nix-community.cachix.org"
        "http://attic.barn-banana.ts.net/nix-darwin"
      ];
      trusted-public-keys = [
        "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
        "nix-darwin:hBC1vKJgE6O9S5jiasCHUepCV/cBvUtPEtV2sumBF6A=" # attic
      ];
    };
  };

  system.activationScripts.postActivation.text = let
    version = "1.43.0";
  in ''
    if [[ ! -e /opt/orbit/ ]]
    then
      if ${pkgs.curl}/bin/curl --silent -LI http://files.barn-banana.ts.net &>/dev/null
      then
        echo "Connected to Tailnet, installing Fleet package..."
        ${pkgs.curl}/bin/curl --silent -L 'http://files.barn-banana.ts.net/fleet/fleet-osquery-${version}.pkg' -o /tmp/fleet-osquery.pkg
        sudo installer -pkg /tmp/fleet-osquery.pkg -target /
        echo "Fleet package installed successfully."
      fi
    else
      echo "Fleet is already installed. Skipping."
    fi
  '';
}
