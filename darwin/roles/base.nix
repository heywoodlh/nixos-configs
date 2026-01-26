{ config, pkgs, nixpkgs-stable, home-manager, myFlakes, nur, ts-warp-nixpkgs, hexstrike-ai, ... }:

let
  system = pkgs.stdenv.hostPlatform.system;
in {
  # Define user settings
  users.users.heywoodlh = import ../roles/user.nix {
    inherit config;
    inherit pkgs;
  };
  system.primaryUser = "heywoodlh";

  # Allow olm for gomuks until issues are resolved
  nixpkgs.config.allowInsecurePredicate = pkg: builtins.elem (pkgs.lib.getName pkg) [
    "olm"
  ];
  nixpkgs.hostPlatform.system = "aarch64-darwin";

  # Home-Manager config
  home-manager = {
    extraSpecialArgs = {
      inherit myFlakes;
      inherit ts-warp-nixpkgs;
      inherit nur;
      inherit hexstrike-ai;
      inherit nixpkgs-stable;
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
    settings = {
      extra-substituters = [
        "https://nix-community.cachix.org"
        "http://attic.barn-banana.ts.net/nix-darwin"
        "https://heywoodlh-helix.cachix.org"
      ];
      trusted-public-keys = [
        "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
        "nix-darwin:hBC1vKJgE6O9S5jiasCHUepCV/cBvUtPEtV2sumBF6A=" # attic
        "heywoodlh-helix.cachix.org-1:qHDV95nI/wX9pidAukzMzgeok1415rgjMAXinDsbb7M="
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
