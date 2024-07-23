{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.heywoodlh.home.lima;
  system = pkgs.system;
  homeDir = config.home.homeDirectory;

  limaArgs = if pkgs.stdenv.isDarwin then "--vm-type=vz" else "";
  startLima = pkgs.writeShellScriptBin "start-lima.sh" ''
      if [[ -e ~/.lima/docker ]]
      then
        ${pkgs.lima}/bin/limactl start docker --mount-writable=true --tty=false
      else
        ${pkgs.lima}/bin/limactl start --mount-writable=true --tty=false --name=docker template://docker-rootful
      fi
  '';
in {
  options = {
    heywoodlh.home.lima = {
      enable = mkOption {
        default = false;
        description = ''
          Run a Lima VM as a service.
        '';
        type = types.bool;
      };
      enableDocker = mkOption {
        default = false;
        description = ''
          Enable Lima VM Docker context.
        '';
        type = types.bool;
      };
    };
  };

  config = mkIf cfg.enable {
    launchd.agents.start-lima = lib.optionalAttrs pkgs.stdenv.isDarwin {
      enable = true;
      config = {
        ProgramArguments = [ "${startLima}/bin/start-lima.sh" ];
        RunAtLoad = true;
        StartInterval = 60; # Re-run every minute
        AbandonProcessGroup = true;
      };
    };

    systemd.user = lib.optionalAttrs pkgs.stdenv.isLinux {
      enable = true;
      services.start-lima = {
        Unit = {
          Description = "Run Lima VM in background.";
        };
        Install = {
          WantedBy = [ "default.target" ];
        };
        Service = {
          ExecStart = "${startLima}/bin/start-lima.sh";
          Type = "oneshot";
        };
      };
      timers."start-lima" = {
        wantedBy = [ "timers.target" ];
        timerConfig = {
          OnCalendar = "*:0/1"; # Re-run every minute
          Unit = "start-lima.service";
        };
      };
    };

    home.packages = with pkgs; [
      lima
      docker-client
      startLima
    ];
    home.activation.docker-context = mkIf cfg.enableDocker ''
      # Create docker context if it doesn't exist
      # Switch to docker context only if it doesn't exist
      # (don't mess with contexts if it already exists)
      if ! ${pkgs.docker-client}/bin/docker context ls | grep -q docker-lima &> /dev/null
      then
        ${pkgs.docker-client}/bin/docker context create docker-lima --docker "host=unix://${homeDir}/.lima/docker/sock/docker.sock" &> /dev/null
        ${pkgs.docker-client}/bin/docker context use docker-lima &> /dev/null
      fi
    '';
  };
}
