{ config, pkgs, ... }:

let
  minikube-start = pkgs.writeScript "minikube-start" ''
    #!/usr/bin/env bash

    ## Start minikube, allowing for remote connections
    minikube start --listen-address=0.0.0.0 \
        --memory=max \
        --cpus=max \
        --driver docker \
        --nodes 3 \
        --apiserver-ips=0.0.0.0 \
        --apiserver-port=8443 \
        --addons=istio,metallb,dashboard
  '';
in {  
  # Minikube package
  environment.systemPackages = with pkgs; [
    minikube
  ];

  # Enable Docker
  virtualisation.docker.enable = true;
  users.users.heywoodlh.extraGroups = [ "docker" ];

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
    ];
    serviceConfig = {
      Type = "simple";
      ExecStart = "${minikube-start}";
      Restart = "on-failure";
      User = "heywoodlh";
    };
    wantedBy = [ "multi-user.target" ];
  };

}
