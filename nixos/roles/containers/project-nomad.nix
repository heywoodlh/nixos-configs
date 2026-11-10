{ config, lib, pkgs, ... }:

let
  baseDir = "/media/services_pool/nomad";
  storage = "${baseDir}/storage";
  kiwixDir = "/media/services_pool/kiwix";
  envFile = "${baseDir}/env";
  network = "project-nomad_default";
  systemDocker = {
    DOCKER_HOST = "unix:///var/run/docker.sock";
    DOCKER_CONTEXT = "default";
  };
  containerNames = [ "nomad-proxy" "nomad-admin" "nomad-mysql" "nomad-redis" "nomad-disk-collector" ];

  initEnv = pkgs.writeShellApplication {
    name = "nomad-init-env";
    runtimeInputs = [ pkgs.coreutils pkgs.gnugrep pkgs.openssl ];
    text = ''
      umask 077
      touch "${envFile}"

      add_key() {
        if ! grep -q "^$1=" "${envFile}"; then
          echo "$1=$2" >> "${envFile}"
        fi
      }

      if ! grep -q "^DB_PASSWORD=" "${envFile}"; then
        db_password="$(openssl rand -hex 24)"
        echo "DB_PASSWORD=$db_password" >> "${envFile}"
        echo "MYSQL_PASSWORD=$db_password" >> "${envFile}"
      fi
      add_key APP_KEY "$(openssl rand -hex 32)"
      add_key MYSQL_ROOT_PASSWORD "$(openssl rand -hex 24)"
      add_key NOMAD_USER nomad
      add_key NOMAD_PASSWORD "$(openssl rand -hex 16)"
    '';
  };

  caddyfile = pkgs.writeText "nomad-Caddyfile" ''
    {
      admin off
      auto_https off
    }

    :8080 {
      basic_auth {
        {$NOMAD_USER} {$NOMAD_PASSWORD_HASH}
      }
      reverse_proxy nomad-admin:8080 {
        flush_interval -1
      }
    }
  '';

  proxyStart = pkgs.writeText "nomad-proxy-start.sh" ''
    #!/bin/sh
    set -eu
    NOMAD_PASSWORD_HASH="$(caddy hash-password --plaintext "$NOMAD_PASSWORD")"
    export NOMAD_PASSWORD_HASH
    exec caddy run --config /etc/caddy/Caddyfile --adapter caddyfile
  '';

  syncZims = pkgs.writeShellApplication {
    name = "nomad-sync-zims";
    runtimeInputs = [ pkgs.coreutils pkgs.curl ];
    text = ''
      cd "${kiwixDir}"
      changed=0
      for target in */*.zim; do
        [ -e "$target" ] || continue
        link="$(basename "$target")"
        if [ -e "$link" ] && [ ! -L "$link" ]; then
          continue
        fi
        if [ "$(readlink "$link" || true)" != "$target" ]; then
          ln -sfn "$target" "$link"
          changed=1
        fi
      done
      for link in ./*.zim; do
        if [ -L "$link" ] && [ ! -e "$link" ]; then
          rm -f "$link"
          changed=1
        fi
      done
      if [ "$changed" = 1 ]; then
        curl -fsS -X POST http://127.0.0.1:8081/api/zim/rescan-library || true
      fi
    '';
  };

  commonOptions = [
    "--network=${network}"
  ];
in {
  networking.firewall.allowedTCPPorts = [ 8080 ];

  systemd.tmpfiles.rules = [
    "d ${baseDir} 0755 root root -"
    "d ${storage} 0755 root root -"
    "d ${storage}/zim 0755 root root -"
    "d ${baseDir}/mysql 0750 999 999 -"
    "d ${baseDir}/redis 0750 999 1000 -"
    "d ${kiwixDir} 0755 root root -"
  ];

  systemd.mounts = [
    {
      what = kiwixDir;
      where = "${storage}/zim";
      type = "none";
      options = "bind";
      wantedBy = [ "multi-user.target" ];
      after = [ "systemd-tmpfiles-setup.service" "zfs-mount.service" ];
      unitConfig.RequiresMountsFor = [ baseDir ];
    }
  ];

  systemd.services = {
    nomad-init-env = {
      description = "Generate Project NOMAD credentials";
      wantedBy = [ "multi-user.target" ];
      after = [ "systemd-tmpfiles-setup.service" "zfs-mount.service" ];
      unitConfig.RequiresMountsFor = [ baseDir ];
      serviceConfig = {
        Type = "oneshot";
        RemainAfterExit = true;
        ExecStart = "${initEnv}/bin/nomad-init-env";
      };
    };

    docker-network-project-nomad = {
      description = "Docker network for Project NOMAD";
      wantedBy = [ "multi-user.target" ];
      after = [ "docker.service" ];
      requires = [ "docker.service" ];
      path = [ config.virtualisation.docker.package ];
      environment = systemDocker;
      serviceConfig = {
        Type = "oneshot";
        RemainAfterExit = true;
      };
      script = ''
        docker network inspect ${network} >/dev/null 2>&1 || docker network create ${network}
      '';
    };

    nomad-sync-zims = {
      description = "Link categorized ZIM files into the flat layout Project NOMAD scans";
      unitConfig.RequiresMountsFor = [ "${storage}/zim" ];
      serviceConfig = {
        Type = "oneshot";
        ExecStart = "${syncZims}/bin/nomad-sync-zims";
      };
    };
  } // lib.genAttrs (map (name: "docker-${name}") containerNames) (name: {
    environment = systemDocker;
    after = [ "nomad-init-env.service" "docker-network-project-nomad.service" "zfs-mount.service" ];
    requires = [ "nomad-init-env.service" "docker-network-project-nomad.service" ];
    unitConfig.RequiresMountsFor = [ "${storage}/zim" ];
  } // lib.optionalAttrs (name == "docker-nomad-admin") {
    preStart = ''
      for _ in $(seq 1 450); do
        if docker exec nomad-mysql mysqladmin ping -h 127.0.0.1 --protocol=tcp --silent; then
          exit 0
        fi
        sleep 2
      done
      echo "nomad-mysql did not become ready" >&2
      exit 1
    '';
  });

  systemd.timers.nomad-sync-zims = {
    wantedBy = [ "timers.target" ];
    timerConfig = {
      OnCalendar = "hourly";
      Persistent = true;
    };
  };

  virtualisation.oci-containers = {
    backend = "docker";
    containers = {
      nomad-mysql = {
        image = "docker.io/library/mysql:8.0.46";
        autoStart = true;
        environment = {
          MYSQL_DATABASE = "nomad";
          MYSQL_USER = "nomad_user";
        };
        environmentFiles = [ envFile ];
        volumes = [
          "${baseDir}/mysql:/var/lib/mysql"
        ];
        extraOptions = commonOptions ++ [
          "--network-alias=mysql"
        ];
      };

      nomad-redis = {
        image = "docker.io/library/redis:7.4.12-alpine";
        autoStart = true;
        volumes = [
          "${baseDir}/redis:/data"
        ];
        extraOptions = commonOptions ++ [
          "--network-alias=redis"
        ];
      };

      nomad-admin = {
        image = "ghcr.io/crosstalk-solutions/project-nomad:v1.35.1";
        autoStart = true;
        dependsOn = [ "nomad-mysql" "nomad-redis" ];
        environment = {
          NODE_ENV = "production";
          NOMAD_STORAGE_PATH = storage;
          PORT = "8080";
          LOG_LEVEL = "info";
          HOST = "0.0.0.0";
          URL = "http://0.0.0.0:8080";
          DB_HOST = "mysql";
          DB_PORT = "3306";
          DB_DATABASE = "nomad";
          DB_USER = "nomad_user";
          DB_NAME = "nomad";
          DB_SSL = "false";
          REDIS_HOST = "redis";
          REDIS_PORT = "6379";
          DISABLE_COMPRESSION = "false";
        };
        environmentFiles = [ envFile ];
        ports = [
          "127.0.0.1:8081:8080"
        ];
        volumes = [
          "${storage}:/app/storage"
          "/var/run/docker.sock:/var/run/docker.sock"
          "nomad-update-shared:/app/update-shared"
        ];
        extraOptions = commonOptions ++ [
          "--add-host=host.docker.internal:host-gateway"
        ];
      };

      nomad-proxy = {
        image = "docker.io/library/caddy:2.11.9-alpine";
        autoStart = true;
        dependsOn = [ "nomad-admin" ];
        environmentFiles = [ envFile ];
        entrypoint = "/bin/sh";
        cmd = [ "/etc/caddy/start.sh" ];
        ports = [
          "8080:8080"
        ];
        volumes = [
          "${caddyfile}:/etc/caddy/Caddyfile:ro"
          "${proxyStart}:/etc/caddy/start.sh:ro"
        ];
        extraOptions = commonOptions;
      };

      nomad-disk-collector = {
        image = "ghcr.io/crosstalk-solutions/project-nomad-disk-collector:v1.31.1";
        autoStart = true;
        volumes = [
          "/:/host:ro,rslave"
          "${storage}:/storage"
        ];
        extraOptions = commonOptions;
      };
    };
  };
}
