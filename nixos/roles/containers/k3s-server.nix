{ config, pkgs, ... }:

let
  system = pkgs.system;
in {
  networking.firewall.allowedTCPPorts = [ 6443 ];
  # https://docs.k3s.io/installation/requirements#networking
  networking.firewall.interfaces.tailscale0.allowedTCPPorts = [ 6443 2379 2380 8472 10250 51820 51821 5001 ];
  networking.firewall.trustedInterfaces = [
    "cni+"
    "tailscale0" # for clustering
  ];
  services.k3s = let
    kubeletConf = pkgs.writeText "kubelet.conf" ''
      apiVersion: kubelet.config.k8s.io/v1beta1
      kind: KubeletConfiguration
      maxPods: 250
    '';
  in {
    package = pkgs.k3s_1_32;
    enable = true;
    role = "server";
    clusterInit = false;
    extraFlags = toString ([
      "--kubelet-arg=config=${kubeletConf}"
      "--kube-controller-manager-arg=node-cidr-mask-size=16"
      "--cluster-cidr 10.42.0.0/16"
      "--service-cidr=10.43.0.0/16"
    ] ++ pkgs.lib.optionals (config.networking.hostName == "homelab") [
      "--tls-san=homelab"
      "--tls-san=nix-nvidia"
      "--tls-san=100.108.77.60"
      "--node-ip=192.168.1.22"
      #"--cluster-reset" # If you change node hostname, uncomment this, rebuild, re-comment and then rebuild again -- completely resets the cluster (CATASTROPHIC DATA LOSS)
    ]);
  };
  environment.systemPackages = [
    pkgs.k3s
    pkgs.nfs-utils
  ];
  systemd.services.k3s.path = with pkgs; [
    ipset
    openiscsi
  ];
  security.pam.loginLimits = [
    {
      domain = "*";
      type = "-";
      item = "nofile";
      value = "9192";
    }
  ];

  virtualisation.docker.enable = true;
}
