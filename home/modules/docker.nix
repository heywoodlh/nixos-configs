{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.heywoodlh.home.dockerBins;
  system = pkgs.system;
in {
  options = {
    heywoodlh.home.dockerBins = {
      enable = mkOption {
        default = false;
        description = ''
          Add heywoodlh docker executables to home.packages.
        '';
        type = types.bool;
      };
    };
  };

  config = mkIf cfg.enable {
    imports = [ ./docker/default.nix ];
  };
}
