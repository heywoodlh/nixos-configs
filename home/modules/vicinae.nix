{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.heywoodlh.home.vicinae;
in {
  options = {
    heywoodlh.home.vicinae = {
      enable = mkOption {
        default = false;
        description = ''
          Enable heywoodlh vicinae configuration.
        '';
        type = types.bool;
      };
    };
  };

  config = mkIf cfg.enable {
    home.packages = with pkgs; [
      vicinae
    ];

    programs.vicinae = {
      enable = true;
      systemd = {
        enable = true;
        autoStart = true;
      };
    };
  };
}
