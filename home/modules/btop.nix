{ config, lib, ... }:

with lib;

let
  cfg = config.heywoodlh.home.btop;
in {
  options = {
    heywoodlh.home.btop = mkOption {
      default = false;
      description = ''
        Enable heywoodlh btop nord configuration.
      '';
      type = types.bool;
    };
  };

  config = mkIf cfg {
    programs.btop.enable = true;
  };
}
