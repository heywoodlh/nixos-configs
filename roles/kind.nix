{ config, pkgs, ... }:

let
  kind-start = pkgs.writeScript "kind-start" ''
    #!/usr/bin/env bash
    ## Create cluster
    kind create cluster --name nix-kind
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
