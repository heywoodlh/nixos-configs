{ config, pkgs, lib, ... }:


with lib;
with lib.types;

let
  cfg = config.heywoodlh.backup;
in {
  options.heywoodlh.backup = {
    enable = mkOption {
      default = false;
      description = "Enable heywoodlh backup client configuration.";
      type = bool;
    };
    username = mkOption {
      default = "backups";
      description = "Username for backups over SSH.";
      type = str;
    };
    publicKeys = mkOption {
      default = [
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIJszbIpuxux7oAANlLC+RphqlEW4Ak1128QMvkI06TiY root@homelab"
      ];
      description = "List of public keys to use for backups.";
      type = listOf singleLineStr;
    };
    server = mkOption {
      default = false;
      description = "Enable heywoodlh backup server (duplicati) configuration.";
      type = bool;
    };
  };

  config = mkIf cfg.enable {
    # Create backup user and group
    users = {
      groups = {
        ${cfg.username} = {};
      };
      users.${cfg.username} = {
        createHome = true;
        isNormalUser = true;
        description = "${cfg.username}";
        group = "${cfg.username}";
        home = "/home/${cfg.username}";
        shell = "${pkgs.bash}/bin/bash";
        openssh.authorizedKeys.keys = cfg.publicKeys;
      };
    };

    services.openssh.settings.Macs = [
     "hmac-sha2-512-etm@openssh.com"
     "hmac-sha2-256-etm@openssh.com"
     "umac-128-etm@openssh.com"
     "hmac-sha2-256"
     "hmac-sha1-96"
     "hmac-sha1"
     "hmac-md5-96"
     "hmac-md5"
    ];
  };
}
