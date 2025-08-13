{ config, pkgs, lib, home-manager, omarchy, myFlakes, ... }:

let
  system = pkgs.system;
in {
  imports = [
    omarchy.nixosModules.default
  ];

  # Omarchy-nix uses greetd
  services.displayManager.gdm.enable = lib.mkForce false;

  programs._1password-gui.polkitPolicyOwners = lib.mkForce ["heywoodlh"];

  # https://github.com/henrysipp/omarchy-nix/blob/main/config.nix
  omarchy = {
    full_name = "Spencer Heywood";
    email_address = "github@heywoodlh.io";
    theme = "nord";
    theme_overrides = {
      wallpaper_path = ../../../assets/e-corp.png;
    };
    quick_app_bindings = [
      "SUPER, return, exec, ${pkgs.ghostty}/bin/ghostty --font-size=12"
    ];
    exclude_packages = with pkgs; [
      chromium
      github-desktop
      lazydocker
      lazygit
      obsidian
      signal-desktop
    ];
  };

  home-manager = {
    users.heywoodlh = {
      imports = [ omarchy.homeManagerModules.default ];
      programs.ghostty.enable = lib.mkForce false;
      programs.git.enable = lib.mkForce false;
      programs.neovim.enable = lib.mkForce false;
      dconf.settings."org/gnome/desktop/interface".gtk-theme = lib.mkForce "Adwaita";
    };
  };
}
