{ config, pkgs, ... }:

{
  networking.firewall = {
    allowedTCPPorts = [
      25
      143
    ];
  };

  virtualisation.oci-containers = {
    backend = "docker";
    containers = {
      protonmailbridge = {
        image = "docker.io/shenxn/protonmail-bridge:3.0.21-1";
        autoStart = true;
        volumes = [
          "/opt/protonmail-bridge/data:/root"
        ];
        ports = [
          "25:25"
          "143:143"
        ];
      };
    };
  };
}
