{
  config,
  lib,
  myPkgs,
  ...
}:
with lib; let
  cfg = config.heywoodlh.helix;
  username = config.heywoodlh.defaults.user.name;
in {
  options.heywoodlh.helix = mkOption {
    default = false;
    description = ''
      Enable heywoodlh Helix configuration.
    '';
    type = types.bool;
  };

  config = mkIf cfg {
    environment.systemPackages = [
      myPkgs.helix
    ];
    home-manager.users.${username}.heywoodlh.home.helix = {
      enable = true;
      ai = true;
    };
    home-manager.users.root.heywoodlh.home.helix = {
      enable = true;
      ai = true;
    };
  };
}
