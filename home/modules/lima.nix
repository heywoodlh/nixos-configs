{ config, lib, pkgs, ... }:

with lib;
with lib.types;

let
  cfg = config.heywoodlh.home.lima;
  homeDir = config.home.homeDirectory;
  nixosLimaVersion = "0.0.5";
  memory = toString cfg.nixos.memory;
  nixosYaml = pkgs.writeText "nixos.yaml" ''
    images:
      - location: "https://github.com/nixos-lima/nixos-lima/releases/download/v${nixosLimaVersion}/nixos-lima-v${nixosLimaVersion}-aarch64.qcow2"
        arch: "aarch64"
      - location: "https://github.com/nixos-lima/nixos-lima/releases/download/v${nixosLimaVersion}/nixos-lima-v${nixosLimaVersion}-x86_64.qcow2"
        arch: "x86_64"
    mounts:
    - location: "~"
      writable: true
    - location: "/tmp/lima"
      writable: true
      9p:
        cache: "mmap"
    memory: ${memory}GiB
    portForwards:
      # Tell Lima's port-forwarding to ignore port 68 to prevent interception of host DHCP packets
      # Apparently this is an issue with NixOS that does not occur on other Linux distros
      # See: https://github.com/nixos-lima/nixos-lima/issues/50
      - proto: udp
        guestPort: 68
        guestIP: 0.0.0.0
        ignore: true
    containerd:
      system: false
      user: false
  '';
  startLima = pkgs.writeShellScript "start-lima.sh" ''
    vm="$1"

    if [[ "$vm" != "nixos" ]] && [[ "$vm" != "docker" ]]
    then
      echo "Usage: start-lima.sh [docker|nixos]" && exit 0
    fi

    if [[ -e "~/.lima/$vm" ]]
    then
      ${pkgs.lima}/bin/limactl start "$vm" --mount-writable=true --tty=false
    else
      template=""
      [[ "$vm" == "docker" ]] && template="template://docker-rootful"
      [[ "$vm" == "nixos" ]] && template="${nixosYaml}"

      ${pkgs.lima}/bin/limactl start --mount-writable=true --tty=false --name="$vm" "$template"
    fi
    if ${pkgs.lima}/bin/limactl list | ${pkgs.gnugrep}/bin/grep -E "^"$vm"" | ${pkgs.gnugrep}/bin/grep -q "Broken"
    then
      echo ""$vm" VM broken, restarting"
      ${pkgs.lima}/bin/limactl stop -f "$vm"
      ${pkgs.lima}/bin/limactl start "$vm"
    fi
  '';
  startDocker = pkgs.writeShellScriptBin "lima-docker.sh" ''
    ${startLima} docker
  '';
  startNixos = pkgs.writeShellScriptBin "lima-nixos.sh" ''
    ${startLima} nixos
  '';
  dockerType = submodule {
    options = {
      enable = mkOption {
        default = true;
        description = ''
          Configure Docker Lima VM.
        '';
        type = bool;
      };
      context = mkOption {
        default = true;
        description = ''
          Configure Lima VM Docker context automatically.
        '';
        type = bool;
      };
    };
  };
  nixosType = submodule {
    options = {
      enable = mkOption {
        default = false;
        description = ''
          Enable NixOS Lima VM.
        '';
        type = bool;
      };
      memory = mkOption {
        default = 4;
        description = ''
          NixOS VM RAM.
        '';
        type = int;
      };
      nixos-rebuild = mkOption {
        default = false;
        description = ''
          Enable `nixos-rebuild` wrapper in Lima.
          Likely should not be enabled on NixOS.
        '';
      };
    };
  };
  enterNixos = pkgs.writeShellScriptBin "nixos.sh" ''
    set -e
    ${startNixos}/bin/lima-nixos.sh
    until ${pkgs.lima}/bin/limactl list | grep nixos | grep -qi running
    do
      echo "Waiting for nixos VM to be started..."
      sleep 5
    done
    ${pkgs.lima}/bin/limactl shell nixos
  '';
  limaNixosRebuild = pkgs.writeShellScriptBin "nixos-rebuild" ''
    ${pkgs.lima}/bin/limactl shell nixos nixos-rebuild $@
  '';
in {
  options = {
    heywoodlh.home.lima = {
      enable = mkOption {
        default = false;
        description = ''
          Enable Lima for Virtual Machines.
        '';
        type = bool;
      };
      docker = mkOption {
        description = "Lima Docker configuration.";
        type = dockerType;
      };
      nixos = mkOption {
        description = "Run a NixOS Lima VM.";
        type = nixosType;
      };
    };
  };

  config = mkIf cfg.enable {
    launchd.agents = lib.optionalAttrs pkgs.stdenv.isDarwin {
      start-lima-docker = {
        enable = cfg.docker.enable;
        config = {
          ProgramArguments = [ "${startDocker}/bin/lima-docker.sh" ];
          RunAtLoad = true;
          StartInterval = 60; # Re-run every minute
          AbandonProcessGroup = true;
        };
      };
      start-lima-nixos = {
        enable = cfg.nixos.enable;
        config = {
          ProgramArguments = [ "${startNixos}/bin/lima-nixos.sh" ];
          RunAtLoad = true;
          StartInterval = 60; # Re-run every minute
          AbandonProcessGroup = true;
        };
      };
    };

    systemd.user = lib.optionalAttrs pkgs.stdenv.isLinux {
      enable = true;
      services = {
        start-lima-docker = lib.optionalAttrs cfg.docker.enable {
          Unit = {
            Description = "Run Lima Docker VM in background.";
          };
          Install = {
            WantedBy = [ "default.target" ];
          };
          Service = {
            ExecStart = "${startDocker}/bin/lima-docker.sh";
            Type = "oneshot";
          };
        };
        start-lima-nixos = lib.optionalAttrs cfg.nixos.enable {
          Unit = {
            Description = "Run Lima NixOS VM in background.";
          };
          Install = {
            WantedBy = [ "default.target" ];
          };
          Service = {
            ExecStart = "${startNixos}/bin/lima-nixos.sh";
            Type = "oneshot";
          };
        };
      };
      timers = {
        "start-lima-docker" = lib.optionalAttrs cfg.docker.enable {
          Unit.Description = "timer for start-lima-docker service";
          Timer = {
            Unit = "start-lima-docker.service";
            OnCalendar = "*:0/1"; # Re-run every minute
          };
        };
        "start-lima-nixos" = lib.optionalAttrs cfg.nixos.enable {
          Unit.Description = "timer for start-lima-nixos service";
          Timer = {
            Unit = "start-lima-nixos.service";
            OnCalendar = "*:0/1"; # Re-run every minute
          };
        };
      };
    };

    home.packages = with pkgs; [
      lima
      # Include docker and nixos starters for dev/testing
      # (will be unused if docker.enable or nixos.enable are false)
      startDocker
      startNixos
      enterNixos
    ] ++ lib.optionals cfg.docker.enable [
      docker-client
    ] ++ lib.optionals cfg.nixos.nixos-rebuild [
      limaNixosRebuild
    ];

    home.activation.docker-context = mkIf (cfg.docker.enable && cfg.docker.context) ''
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
