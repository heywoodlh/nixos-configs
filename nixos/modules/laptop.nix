{ config, pkgs, lib, ... }:

with lib;
with lib.types;

let
  cfg = config.heywoodlh.laptop;
  system = pkgs.stdenv.hostPlatform.system;
in {
  options.heywoodlh.laptop = mkOption {
    default = false;
    type = bool;
  };

  config = mkIf cfg {
    heywoodlh.workstation = true;
    system.activationScripts = {
      powerSaver = ''
        ${pkgs.power-profiles-daemon}/bin/powerprofilesctl set power-saver &>/dev/null || true
      '';
    };
  };
}
