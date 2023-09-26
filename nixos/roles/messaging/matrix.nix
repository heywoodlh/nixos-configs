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
        image = "dock.mau.dev/mautrix/wsproxy:latest";
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
        cmd = [
          "/usr/bin/mautrix-wsproxy"
          "-config"
          "/data/config.yaml"
        ];
      };
      mautrix-signal = {
        image = "dock.mau.dev/mautrix/signal:latest";
        autoStart = true;
        volumes = [
          "/opt/mautrix-signal/data:/data"
          "/run/signald:/signald"
          "/etc/localtime:/etc/localtime:ro"
        ];
        extraOptions = [
          "--network=host"
        ];
        environment = {
          HOMESERVER_URL = "http://localhost:8008";
        };
      };
    };
  };

  # Discord AppService
  #services.matrix-appservice-discord = {
  #  enable = true;
  #  port = 9005;
  #  environmentFile = "/opt/matrix-discord/environment";
  #  settings = {};
  #};

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

}
