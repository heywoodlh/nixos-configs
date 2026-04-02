{ config, lib, ... }:

with lib;

let
  cfg = config.heywoodlh.nixos.steam-deck;
in {
  options.heywoodlh.nixos.steam-deck = mkOption {
    default = false;
    description = ''
      Enable heywoodlh Steam Deck configuration.
    '';
    type = types.bool;
  };
  config = mkIf cfg {
    heywoodlh.nixos.gaming = true;
    jovian = {
      steam = {
        enable = true;
        autoStart = true;
        user = cfg.user;
        desktopSession = mkIf config.heywoodlh.hyprland "hyprland";
      };
      devices.steamdeck.enable = true;
    };
  };
}
