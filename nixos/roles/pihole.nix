{ config, pkgs, ... }:

{
  networking.firewall = {
    allowedUDPPorts = [
      53
      67
    ];
    allowedTCPPorts = [
      53
      8000
    ];
  };

  virtualisation.oci-containers = {
    backend = "docker";
    containers = {
      pihole = {
        image = "docker.io/pihole/pihole:2023.03.1";
        autoStart = true;
        ports = [
          "53:53"
          "53:53/udp"
          "67:67/udp"
          "8000:80"
        ];
        volumes = [
          "/opt/pihole/etc-pihole:/etc/pihole"
          "/opt/pihole/etc-dnsmasq.d:/etc/dnsmasq.d"
          "/opt/pihole/log:/var/log/pihole"
        ];
        environmentFiles = [
          "/opt/pihole/pihole.env"
        ];
        extraOptions = [
          "--cap-add=NET_ADMIN"
        ];
      };
      cloudflared = {
        image = "docker.io/cloudflare/cloudflared:2023.4.0";
        autoStart = true;
        cmd = [
          "cloudflared"
          "--config"
          "/etc/cloudflared/config.yml"
          "--no-autoupdate"
          "--origincert"
          "/etc/cloudflared/cert.pem"
        ];
        ports = [
          "5053:5053"
          "5053:5053/udp"
        ];
        volumes = [
          "/opt/cloudflared:/etc/cloudflared"
        ];
      };
    };
  };
}
