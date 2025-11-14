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

  services.displayManager.defaultSession = "hyprland";

  # Enable hyprland
  programs.hyprland = {
    enable = true;
    xwayland.enable = true;
  };
  security.pam.services.swaylock.text = "auth include login";
  hardware.brillo.enable = true;

  home-manager.users.heywoodlh = {
    imports = [
      hyprland.homeManagerModules.default
      ../../../home/linux/hyprland.nix
    ];
    wayland.windowManager.hyprland.extraConfig = ''
      env = NIXOS_OZONE_WL, 1
    '';
  };
}
