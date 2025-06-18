{ config, pkgs, home-manager, ... }:

let
  system = pkgs.system;
in {
  imports = [
    ./desktop.nix
  ];

  home-manager.users.heywoodlh.imports = [
    ../home/linux/hyprland/laptop.nix
  ];

  system.activationScripts = {
    powerSaver = ''
      ${pkgs.power-profiles-daemon}/bin/powerprofilesctl set power-saver &>/dev/null || true
    '';
  };
}
