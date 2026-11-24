{ config, lib, ... }:

with lib;

let
  cfg = config.heywoodlh.nixos.spotify-soloist;
in
{
  options.heywoodlh.nixos.spotify-soloist = {
    enable = mkOption {
      default = false;
      description = "Allow LAN clients to reach the Spotify Soloist Connect port.";
      type = types.bool;
    };
    ports = mkOption {
      default = { };
      description = "TCP port range Spotify Soloist may bind its Connect endpoint to.";
      type = types.submodule {
        options = {
          from = mkOption {
            default = 32768;
            description = "First TCP port of the allowed range.";
            type = types.port;
          };
          to = mkOption {
            default = 60999;
            description = "Last TCP port of the allowed range.";
            type = types.port;
          };
        };
      };
    };
  };

  config = mkIf cfg.enable {
    networking.firewall.allowedTCPPortRanges = [ { inherit (cfg.ports) from to; } ];
  };
}
