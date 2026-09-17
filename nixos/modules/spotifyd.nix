{ config, lib, ... }:

with lib;

let
  cfg = config.heywoodlh.nixos.spotifyd;
in {
  options.heywoodlh.nixos.spotifyd.enable = mkOption {
    default = false;
    description = "Enable Spotify Connect playback through spotifyd.";
    type = types.bool;
  };

  config = mkIf cfg.enable {
    services.spotifyd = {
      enable = true;
      settings.global = {
        backend = "alsa";
        device = "default";
        device_name = config.networking.hostName;
        device_type = "computer";
      };
    };
  };
}
