{ config, pkgs, home-manager, mullvad-browser-home-manager, myFlakes, choose-nixpkgs, ... }:
{
  # Define user settings
  users.users.heywoodlh = import ../roles/user.nix {
    inherit config;
    inherit pkgs;
  };

  # Home-Manager config
  home-manager = {
    extraSpecialArgs = {
      inherit myFlakes;
      inherit choose-nixpkgs;
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
}
