{ config, pkgs, lib, ... }:

with lib;
with lib.types;

let
  cfg = config.heywoodlh.nixos.tor;
  username = config.heywoodlh.defaults.user.name;
in {
  options.heywoodlh.nixos.tor = {
    enable = mkOption {
      default = false;
      description = "Enable heywoodlh Tor client configuration.";
      type = bool;
    };
    entryNodes = mkOption {
      default = "{US} StrictNodes 1";
      description = "Entry node countries. Set to US for speed (but less privacy).";
      type = str;
    };
    exitNodes = mkOption {
      default = "{US} StrictNodes 1";
      description = "Exit node countries. Set to US for speed (but less privacy).";
      type = str;
    };
  };

  config = mkIf cfg.enable {
    # Configure LibreWolf to use Tor's built-in SOCKS proxy
    home-manager.users.${username} = {
      heywoodlh.home.librewolf = {
        enable = true;
        socks = {
          proxy = mkForce "127.0.0.1";
          port = mkForce 9050;
        };
      };
    };

    environment.systemPackages = lib.optionals (pkgs.stdenv.isx86_64) [
      pkgs.tor-browser
    ];
    services.tor = {
      enable = true;
      torsocks.enable = true;
      client.enable = true;
      settings = {
        EntryNodes = cfg.entryNodes;
        ExitNodes = cfg.exitNodes;
      };
    };
  };
}
