{ config, pkgs, home-manager, hyprland, ... }:

{
  nix.settings = {
    sandbox = true;
    substituters = [
      "https://hyprland.cachix.org"
    ];
    trusted-public-keys = [
      "hyprland.cachix.org-1:a7pgxzMz7+chwVL3/pzj6jIBMioiJM7ypFP8PwtkuGc="
    ];
  };

  # Enable hyprland
  programs.hyprland = {
    enable = true;
    xwayland.enable = true;
  };
  services.displayManager.defaultSession = "hyprland";
  security.pam.services.swaylock.text = "auth include login";
  hardware.brillo.enable = true;

  home-manager.users.heywoodlh.imports = [
    hyprland.homeManagerModules.default
    ../../../home/linux/hyprland.nix
  ];
}
