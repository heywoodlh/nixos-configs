{ config, pkgs, home-manager, ... }:

let
  system = pkgs.system;
in {
  imports = [
    ./desktop.nix
  ];

  system.activationScripts = {
    powerSaver = ''
      ${pkgs.power-profiles-daemon}/bin/powerprofilesctl set power-saver &>/dev/null || true
    '';
  };
}
