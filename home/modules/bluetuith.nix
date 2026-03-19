{ config, lib, ... }:

with lib;

let
  cfg = config.heywoodlh.home.bluetuith;
in {
  options = {
    heywoodlh.home.bluetuith = mkOption {
      default = false;
      description = ''
        Enable heywoodlh Vim-keybindings bluetuith configuration.
      '';
      type = types.bool;
    };
  };

  config = mkIf cfg {
    programs.bluetuith = {
      enable = true;
      settings = {
        keybindings = {
          "FilebrowserDirBackward" = "h";
          "FilebrowserDirForward" = "l";
          "FilebrowserToggleHidden" = ".";
          "NavigateBottom" = "g";
          "NavigateDown" = "j";
          "NavigateLeft" = "h";
          "NavigateRight" = "l";
          "NavigateTop" = "G";
          "NavigateUp" = "k";
          "Quit" = "q";
        };
      };
    };
  };
}
