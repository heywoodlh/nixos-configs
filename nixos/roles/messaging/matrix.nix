{ config, pkgs, ... }:

let
  fqdn = "matrix.heywoodlh.io";
  clientConfig."m.homeserver".base_url = "https://matrix.heywoodlh.io";
in {
  networking.firewall.interfaces.tailscale0 = {
    allowedTCPPorts = [
      80
      8008
      29331
    ];
  };

  services.postgresql.enable = true;
  services.postgresql.initialScript = pkgs.writeText "synapse-init.sql" ''
    CREATE ROLE "matrix-synapse" WITH LOGIN PASSWORD 'synapse';
    CREATE DATABASE "matrix-synapse" WITH OWNER "matrix-synapse"
      TEMPLATE template0
      LC_COLLATE = "C"
      LC_CTYPE = "C";
  '';

  services.matrix-synapse = {
    enable = true;
    #extraConfigFiles = [
    #  "/opt/synapse/extra.conf"
    #];
    settings = {
      server_name = "matrix.heywoodlh.io";
      #enable_registration = true;
      public_baseurl = "https://${fqdn}";
      app_service_config_files = [
        "/opt/mautrix-wsproxy/registration.yaml"
        "/opt/mautrix-signal/data/registration.yaml"
        "/opt/mautrix-discord/data/registration.yaml"
      ];
      listeners = [
        {
          port = 8008;
          bind_addresses = [ "0.0.0.0" ];
          type = "http";
          tls = false;
          x_forwarded = true;
          resources = [{
            names = [ "client" "federation" ];
            compress = true;
          }];
        }
      ];
    };
  };

  virtualisation.oci-containers = {
    backend = "docker";
    containers = {
      element-web = {
        image = "docker.io/vectorim/element-web:latest";
        autoStart = true;
        volumes = [
          "/etc/localtime:/etc/localtime:ro"
        ];
        extraOptions = [
          "--network=host"
        ];
      };
      mautrix-wsproxy = {
        image = "dock.mau.dev/mautrix/wsproxy:01e263da210a268fcfa715c7e051fb6913b2226a-amd64";
        autoStart = true;
        volumes = [
          "/opt/mautrix-wsproxy/data:/data"
          "/etc/localtime:/etc/localtime:ro"
        ];
        extraOptions = [
          "--network=host"
        ];
        environment = {
          APPSERVICE_ID = "imessage";
        };
        environmentFiles = [
          /opt/mautrix-wsproxy/environment
        ];
      };
      mautrix-signal = {
        image = "dock.mau.dev/mautrix/signal:370a85354f56e44fff7744764a75e3f5f74b8761-amd64";
        autoStart = true;
        user = "994:994";
        volumes = [
          "/opt/mautrix-signal/data:/data"
          "/run/signald:/signald"
          "/etc/localtime:/etc/localtime:ro"
        ];
        extraOptions = [
          "--network=host"
        ];
        environment = {
          HOMESERVER_URL = "https://matrix.heywoodlh.io";
        };
      };
      mautrix-discord = {
        image = "dock.mau.dev/mautrix/discord:v0.6.3";
        autoStart = true;
        volumes = [
          "/opt/mautrix-discord/data:/data"
          "/etc/localtime:/etc/localtime:ro"
        ];
        extraOptions = [
          "--network=host"
        ];
      };
    };
  };

  # Signald
  services.signald = {
    enable = true;
    group = "signald";
    socketPath = "/run/signald/signald.sock";
  };
  # Restart signald daily
  systemd.timers."restart-signald" = {
    wantedBy = [ "timers.target" ];
      timerConfig = {
        OnCalendar = "daily";
        Unit = "restart-signald.service";
      };
  };
  systemd.services."restart-signald" = {
    script = ''
      set -eu
      systemctl restart signald.service
      sleep 20
      systemctl restart docker-mautrix-signal.service
    '';
    serviceConfig = {
      Type = "oneshot";
      User = "root";
    };
  };
  users.groups.signald.members = [
    "heywoodlh"
    "signald"
  ];
  environment.systemPackages = with pkgs; [
    signaldctl
  ];

  # Fix mautrix-discord registration permissions
  systemd.services."matrix-synapse".serviceConfig = {
    execStartPre = [
      "chmod +r /opt/mautrix-discord/data/registration.yaml"
    ];
  };
}
