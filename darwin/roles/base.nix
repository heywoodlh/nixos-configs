{ config, pkgs, determinate-nix, home-manager, myFlakes, nur, ts-warp-nixpkgs, qutebrowser, ghostty, ... }:

let
  system = pkgs.system;
  nixPkg = determinate-nix.packages.${system}.default;
in {
  # Define user settings
  users.users.heywoodlh = import ../roles/user.nix {
    inherit config;
    inherit pkgs;
  };

  # Allow olm for gomuks until issues are resolved
  nixpkgs.config.permittedInsecurePackages = [
    "olm-3.2.16"
  ];

  # Home-Manager config
  home-manager = {
    extraSpecialArgs = {
      inherit myFlakes;
      inherit ts-warp-nixpkgs;
      inherit qutebrowser;
      inherit ghostty;
      inherit nur;
      inherit determinate-nix;
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
        "nix-darwin:iDh77oS0PRmAJ+NMqECp7HzvA0ycgKd/kqjMz2wQJeU=" # attic
      ];
    };
  };
}
