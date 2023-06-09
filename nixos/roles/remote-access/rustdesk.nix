{ config, pkgs, ... }:

{
  networking.firewall = {
    allowedTCPPorts = [
      21115
      21116
      21117
      21118
      21119
    ];
    allowedUDPPorts = [
      21115
      21116
    ];
  };

  # Enable docker-nvidia
  hardware.opengl.driSupport32Bit = true;
  virtualisation.docker = {
    enableNvidia = true;
  };

  system.activationScripts.mkrustdeskNet = ''
    ${pkgs.docker}/bin/docker network create rustdesk &2>/dev/null || true
  '';

  virtualisation.oci-containers = {
    backend = "docker";
    containers = {
      rustdesk-hbbs = {
        image = "docker.io/rustdesk/rustdesk-server:latest";
        autoStart = true;
        ports = [
          "21115:21115"
          "21116:21116"
          "21116:21116/udp"
          "21118:21118"
        ];
        volumes = [
          "/opt/rustdesk/:/root"
          "/etc/localtime:/etc/localtime:ro"
        ];
        cmd = [
          "hbbs"
          "-r"
          "rustdesk-hbbr:21117"
        ];
      };
      rustdesk-hbbr = {
        image = "docker.io/rustdesk/rustdesk-server:latest";
        autoStart = true;
        dependsOn = ["rustdesk-hbbr"];
        ports = [
          "21117:21117"
          "21119:21119"
        ];
        extraOptions = [
          "--network=rustdesk"
        ];
        volumes = [
          "/opt/rustdesk/:/root"
          "/etc/localtime:/etc/localtime:ro"
        ];
        cmd = [
          "hbbr"
        ];
      };
    };
  };
}
