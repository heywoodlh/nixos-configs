{ config, pkgs, ... }:

let
  system = pkgs.system;
in {
  imports = [
    ./desktop.nix
  ];

  system.activationScripts = {
    powerSaver = ''
      ${pkgs.power-profiles-daemon}/bin/powerprofilesctl set power-saver
    '';
  };
}
