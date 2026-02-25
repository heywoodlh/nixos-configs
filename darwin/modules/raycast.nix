{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.heywoodlh.darwin.raycast;
in {
  options = {
    heywoodlh.darwin.raycast = {
      enable = mkOption {
        default = false;
        description = ''
          Enable heywoodlh Raycast configuration.
        '';
        type = types.bool;
      };
      user = mkOption {
        default = "";
        description = ''
          Which user to change Cmd+Space shortcut for Spotlight to Ctrl+Shift+Space.
          If unset, does not change shortcut.
          Reboot required for Spotlight shortcut to apply. Sometimes doesn't work, change manually if needed.
        '';
        type = types.str;
      };
    };
  };

  config = mkIf cfg.enable {
    homebrew.casks = [
      "raycast"
    ];

    # Nest in lib.optionalAttrs in case cfg.user is unset
    home-manager.users = lib.optionalAttrs (cfg.user != "") {
      "${cfg.user}".heywoodlh.home.darwin.disable-spotlight = true;
    };
  };
}
