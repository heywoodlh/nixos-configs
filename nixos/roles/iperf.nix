{ config, pkgs, ... }:

{
  networking.firewall.allowedTCPPorts = [
    5201
  ];

  virtualisation.oci-containers = {
    backend = "docker";
    containers = {
      iperf3 = {
        image = "docker.io/heywoodlh/iperf3:3.13-2";
        autoStart = true;
        ports = ["5201:5201"];
        cmd = [
          "--server"
        ];
      };
    };
  };
}
