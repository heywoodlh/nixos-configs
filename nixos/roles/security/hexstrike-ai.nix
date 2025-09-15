{ config, pkgs, hexstrike-ai, ... }:

let
  system = pkgs.system;
  hexstrike-ai-pkg = hexstrike-ai.packages.${system}.hexstrike-ai-server;
  hexstrike-ai-container = pkgs.dockerTools.buildImage {
    name = "docker.io/heywoodlh/hexstrike-ai";
    tag = "latest";

    copyToRoot = pkgs.buildEnv {
      name = "image-root";
      paths = [
        pkgs.bash
        pkgs.busybox
        pkgs.coreutils
        pkgs.python3
        hexstrike-ai-pkg
      ];
      pathsToLink = [ "/usr/local/bin" ];
    };

    runAsRoot = ''
      #!${pkgs.runtimeShell}
      mkdir -p /data
    '';

    config = {
      Cmd = [ "${hexstrike-ai-pkg}/bin/hexstrike_server.py" ];
      WorkingDir = "/data";
      Volumes = { "/data" = {}; };
    };
  };
in {
  networking.firewall.interfaces.tailscale0.allowedTCPPorts = [
    8888
  ];

  virtualisation.oci-containers = {
    backend = "docker";
    containers = {
      hexstrike-ai = {
        image = "docker.io/heywoodlh/hexstrike-ai";
        imageFile = hexstrike-ai-container;
        autoStart = true;
        ports = [
          "100.108.77.60:8888:8888"
        ];
        volumes = [
          "/etc/localtime:/etc/localtime:ro"
        ];
      };
    };
  };
}
