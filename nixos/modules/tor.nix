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
    socksPort = mkOption {
      default = 9050;
      description = "Local SOCKS proxy port.";
      type = int;
    };
  };

  config = mkIf cfg.enable {
    # Configure LibreWolf to use Tor's built-in SOCKS proxy
    home-manager.users.${username} = {
      heywoodlh.home.librewolf = {
        enable = true;
        socks = {
          proxy = mkForce "127.0.0.1";
          port = mkForce cfg.socksPort;
        };
      };
    };

    environment.systemPackages = [
      pkgs.tor-browser
    ];
    services.tor = {
      torsocks.enable = true;
      client = {
        enable = true;
        socksListenAddress = {
          IsolateDestAddr = true;
          addr = "127.0.0.1";
          port = cfg.socksPort;
        };
      };
      settings = {
        EntryNodes = cfg.entryNodes;
        ExitNodes = cfg.exitNodes;
        StrictNodes = true;
        ClientOnly = true;
        LearnCircuitBuildTimeout = true;
        CircuitBuildTimeout = 10;
        NumEntryGuards = 8;
        NumPreemptiveCircuits = 10;
        MaxClientCircuitsPending = 48;
        FetchDirInfoEarly = true;
        FetchDirInfoExtraEarly = true;
      };
    };
  };
}
