{ config, pkgs, ... }:

{
  networking.firewall.allowedTCPPorts = [
    8182
  ];

  virtualisation.oci-containers = {
    backend = "docker";
    containers = {
      sshwifty = {
        image = "docker.io/niruix/sshwifty:0.2.32-beta-release";
        ports = ["10.50.50.31:8182:8182"];
        #volumes = [
        #  "/opt/sshwifty:/config"
        #];
      };
    };
  };
}
