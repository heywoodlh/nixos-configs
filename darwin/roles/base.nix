{ config, pkgs, home-manager, mullvad-browser-home-manager, myFlakes, ts-warp-nixpkgs, qutebrowser, ... }:
{
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
    };
    # Set home-manager configs for heywoodlh
    users.heywoodlh = { ... }: {
      imports = [
        (mullvad-browser-home-manager + /modules/programs/mullvad-browser.nix)
        ../../home/darwin.nix
        ../../home/roles/atuin.nix
      ];
    };
  };

  environment.etc."ssh/ssh_config".text = ''
    Host *
      SendEnv LANG LC_*
    IdentityAgent /Users/heywoodlh/Library/Group\ Containers/2BUA8C4S2C.com.1password/t/agent.sock
    Include /etc/ssh/ssh_config.d/*
  '';

  nix.settings = {
    substituters = [
      "https://nix-community.cachix.org"
      "http://attic.barn-banana.ts.net/nix-darwin"
    ];
    trusted-public-keys = [
      "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
      "nix-darwin:So8WZjJEaRb7LAm9t3cCIMS+d1C5Pu+fG1TkhOnKdYs=" # attic
    ];
  };
}
