{ config, pkgs, home-manager, omarchy, ... }:

{
  imports = [
    omarchy.nixosModules.default
  ];

  _1password-gui.polkitPolicyOwners = ["heywoodlh"];

  # https://github.com/henrysipp/omarchy-nix/blob/main/config.nix
  omarchy = {
    full_name = "Spencer Heywood";
    email_address = "github@heywoodlh.io";
    theme = "nord";
    exclude_packages = with pkgs; [
      chromium
      dropbox
      github-desktop
      lazydocker
      lazygit
      obsidian
      signal-desktop
      spotify
      typora
    ];
  };

  home-manager = {
    extraSpecialArgs = {
      inherit omarchy;
    };
    users.heywoodlh = {
       imports = [
        ../../../home/linux/omarchy.nix
       ];
    };
  };
}
