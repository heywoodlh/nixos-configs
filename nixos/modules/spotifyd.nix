{ config, lib, ... }:

with lib;

let
  cfg = config.heywoodlh.nixos.spotifyd;
  username = config.heywoodlh.defaults.user.name;
in {
  options.heywoodlh.nixos.spotifyd = {
    enable = mkOption {
      default = false;
      description = "Enable Spotify Connect playback through spotifyd.";
      type = types.bool;
    };
    ports = mkOption {
      default = {};
      description = "Network ports used for Spotify Connect discovery.";
      type = types.submodule {
        options = {
          mdns = mkOption {
            default = 5353;
            description = "UDP port used for mDNS service advertisement.";
            type = types.port;
          };
          zeroconf = mkOption {
            default = 1234;
            description = "TCP port used for Spotify Connect discovery.";
            type = types.port;
          };
        };
      };
    };
  };

  config = mkIf cfg.enable {
    networking.firewall = {
      allowedTCPPorts = [ cfg.ports.zeroconf ];
      allowedUDPPorts = [ cfg.ports.mdns ];
    };
    home-manager.users.${username}.services.spotifyd = {
      enable = true;
      settings.global = {
        backend = "alsa";
        device = "default";
        device_name = config.networking.hostName;
        device_type = "computer";
        zeroconf_port = cfg.ports.zeroconf;
      };
    };
  };
}
