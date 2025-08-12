{ config, pkgs, lib, home-manager, omarchy, ... }:

{
  imports = [
    omarchy.nixosModules.default
  ];

  services.displayManager.defaultSession = lib.mkForce "hyprland";

  programs._1password-gui.polkitPolicyOwners = lib.mkForce ["heywoodlh"];

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
