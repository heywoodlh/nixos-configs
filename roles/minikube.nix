{ config, pkgs, ... }:

let
  minikube-start = pkgs.writeScript "minikube-start" ''
    #!/usr/bin/env bash

    ## Assumes that an IP in 10.50.50.0/24 exists on host
    ip_address="$(ip addr | grep 10.50.50 | awk '{print $2}' | cut -d'/' -f1)"

    ## Start minikube, allowing for remote connections
    minikube start --listen-address=0.0.0.0 \
        --memory=max \
        --cpus=max \
        --driver docker \
        --nodes 3 \
        --apiserver-ips=''${ip_address} \
        --apiserver-port=8443 \
        --addons=istio,metallb,dashboard \
        --ports=8443:8443
  '';
in {  
  # Minikube package
  environment.systemPackages = with pkgs; [
    kubectl
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
