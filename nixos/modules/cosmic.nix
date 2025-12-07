{ config, lib, cosmic-home-manager, ... }:

with lib;

let
  cfg = config.heywoodlh.cosmic;
  username = config.heywoodlh.defaults.user.name;
in {
  options.heywoodlh.cosmic = mkOption {
    default = false;
    description = ''
      Enable heywoodlh cosmic desktop configuration.
    '';
    type = types.bool;
  };

  config = mkIf cfg {
    services.desktopManager.cosmic.enable = true;
    home-manager.users.${username} = {
      imports = [
        cosmic-home-manager.homeManagerModules.cosmic-manager
      ];
      heywoodlh.home.cosmic = true;
    };
  };
}
