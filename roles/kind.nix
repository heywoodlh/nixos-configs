{ config, pkgs, ... }:

let
  kind-start = pkgs.writeScript "kind-start" ''
    #!/usr/bin/env bash
    ## Create cluster
cat <<EOF | kind create cluster --name=nix-kind --config=-
kind: Cluster
apiVersion: kind.x-k8s.io/v1alpha4
nodes:
- role: control-plane
  kubeadmConfigPatches:
  - |
    kind: InitConfiguration
    nodeRegistration:
      kubeletExtraArgs:
        node-labels: "ingress-ready=true"
  extraPortMappings:
  - containerPort: 80
    hostPort: 80
    protocol: TCP
  - containerPort: 443
    hostPort: 443
    protocol: TCP
  - containerPort: 8443
    hostPort: 8443
    protocol: TCP
  extraMounts:
  - hostPath: /dev
    containerPath: /dev
  - hostPath: /var/run/docker.sock
    containerPath: /var/run/docker.sock
  '';
in {  
  # Kubernetes packages
  environment.systemPackages = with pkgs; [
    kind
    kubectl
  ];

  # Allow remote connections
  networking.firewall.allowedTCPPorts = [
    8443
  ];

  # Enable docker
  virtualisation.docker.enable = true;
  users.users.heywoodlh.extraGroups = [ "docker" ];

  systemd.services.kind = {
    description = "Start Kind";
    path = [ 
      pkgs.bash
      pkgs.docker
      pkgs.kind
      pkgs.systemd 
    ];
    serviceConfig = {
      Type = "simple";
      ExecStart = "${kind-start}";
      Restart = "on-failure";
      User = "heywoodlh";
    };
    wantedBy = [ "multi-user.target" ];
  };
}
