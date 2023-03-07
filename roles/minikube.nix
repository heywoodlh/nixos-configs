{ config, pkgs, ... }:

let
  minikube-start = pkgs.writeScript "minikube-start" ''
    #!/usr/bin/env bash

    ## Start minikube, allowing for remote connections
    minikube start --listen-address=0.0.0.0 \
        --driver=none \
        --nodes 3 \
        --addons=istio,metallb,dashboard \
        --force
  '';
in {  
  # Minikube package
  environment.systemPackages = with pkgs; [
    kubectl
    minikube
  ];

  # Allow remote connections
  networking.firewall.allowedTCPPorts = [
    8443
  ];

  systemd.services.minikube-start = {
    description = "Start Minikube";
    path = [ 
      pkgs.bash
      pkgs.docker
      pkgs.minikube 
      pkgs.systemd 
      pkgs.system-path
    ];
    serviceConfig = {
      Type = "simple";
      ExecStart = "${minikube-start}";
      Restart = "on-failure";
      User = "root";
    };
    wantedBy = [ "multi-user.target" ];
  };
}
