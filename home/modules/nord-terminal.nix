{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.heywoodlh.home.darwin.nord-terminal;
  homeDir = config.home.homeDirectory;
  plist = ./com.apple.Terminal.plist;
in {
  options = {
    heywoodlh.home.darwin.nord-terminal = mkOption {
      default = false;
      description = ''
        Enable heywoodlh Terminal.app Nord configuration.
        Warning: will overwrite existing settings.
      '';
      type = types.bool;
    };
  };

  config = mkIf cfg {
    home.activation.nord-terminal = ''
      /bin/cp ${plist} ${homeDir}/Library/Preferences/com.apple.Terminal.plist
    '';
  };
}
