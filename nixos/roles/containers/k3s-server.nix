{ config, pkgs, ... }:

let
  system = pkgs.system;
in {
  networking.firewall.allowedTCPPorts = [ 6443 ];
  # https://docs.k3s.io/installation/requirements#networking
  networking.firewall.interfaces.tailscale0.allowedTCPPorts = [ 6443 2379 2380 8472 10250 51820 51821 5001 ];
  networking.firewall.trustedInterfaces = [ "tailscale0" ]; # for clustering
  services.k3s = let
    kubeletConf = pkgs.writeText "kubelet.conf" ''
      apiVersion: kubelet.config.k8s.io/v1beta1
      kind: KubeletConfiguration
      maxPods: 250
    '';
  in {
    package = pkgs.k3s.override {
      overrideBundleAttrs = {
        src = pkgs.fetchgit {
          url = "https://github.com/k3s-io/k3s";
          rev = "7837d29269970088eaa019a2d7e61ecdfb68d985";
          sha256 = "sha256-8voWwI3dWzG3E8TJet0m+TcMialM16AZA1/fMPH/DnY=";
        };
        vendorHash = "sha256-Wgla9Cyq5U9Q0xs/C/iyAMwHkIug7ernl7w5mn3gSco=";
      };
    };
    enable = true;
    role = "server";
    clusterInit = false;
    extraFlags = toString ([
      "--kubelet-arg=config=${kubeletConf}"
      "--kube-controller-manager-arg=node-cidr-mask-size=16"
      "--cluster-cidr 10.42.0.0/16"
      "--service-cidr=10.43.0.0/16"
    ] ++ pkgs.lib.optionals (config.networking.hostName == "nix-nvidia") [
      "--tls-san=nix-nvidia"
      "--tls-san=100.108.77.60"
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
