{ config, lib, ... }:

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
    heywoodlh.defaults.enable = true;
    services.desktopManager.cosmic.enable = true;
    home-manager.users.${username}.heywoodlh.home.cosmic = true;
  };
}
