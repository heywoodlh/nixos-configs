{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.heywoodlh.darwin.stage-manager;
  system = pkgs.system;
in {
  options = {
    heywoodlh.darwin.stage-manager = {
      enable = mkOption {
        default = false;
        description = ''
          Enable heywoodlh Stage Manager config.
        '';
        type = types.bool;
      };
    };
  };

  config = mkIf cfg.enable {
    system.defaults.WindowManager = {
      AutoHide = true;
      EnableStandardClickToShowDesktop = false;
      GloballyEnabled = true;
      HideDesktop = true;
      StageManagerHideWidgets = true;
      AppWindowGroupingBehavior = true;
    };
  };
}
