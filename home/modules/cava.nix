{ config, lib, ... }:

with lib;

let
  cfg = config.heywoodlh.home.cava;
in {
  options = {
    heywoodlh.home.cava = mkOption {
      default = false;
      description = ''
        Enable heywoodlh cava configuration.
      '';
      type = types.bool;
    };
  };

  config = mkIf cfg {
    programs.cava = {
      enable = true;
      settings.general.framerate = 60;
    };
  };
}
