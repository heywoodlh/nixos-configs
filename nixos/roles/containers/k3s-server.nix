{ config, pkgs, home-manager, ... }:

let
  system = pkgs.stdenv.hostPlatform.system;
  lib = pkgs.lib;
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

  systemd.timers."k3s-cleanup-failed-admission" = {
    wantedBy = [ "timers.target" ];
    timerConfig = {
      OnBootSec = "5m";
      OnUnitActiveSec = "5m";
      Unit = "k3s-cleanup-failed-admission.service";
    };
  };

  systemd.services."k3s-cleanup-failed-admission" = {
    script = ''
      # Script for cleaning up old pods stuck in UnexpectedAdmissionError state
      # Caused by Intel GPU passthrough
      kubectl get pods -A | grep -E 'UnexpectedAdmissionError|ContainerStatusUnknown|Unknown' | while read line
      do
        namespace=$(echo $line | awk '{print $1}')
        pod=$(echo $line | awk '{print $2}')
        kubectl delete -n $namespace pod $pod
      done
    '';
    description = "Removed pods with FailedAdmission status";
    environment = {
      KUBECONFIG = "/etc/rancher/k3s/k3s.yaml";
    };
    path = with pkgs; [
      gawk
      gnugrep
      findutils
      coreutils
      kubectl
    ];
    serviceConfig = {
      Type = "oneshot";
      User = "root";
    };
  };

  systemd.services = {
    k3s.path = with pkgs; [
      ipset
      openiscsi
    ];
    k3s-kubeconfig = let
      setupConfig = pkgs.writeShellScript "k3s-setup-config" ''
        mkdir -p /opt/k3s
        cp /etc/rancher/k3s/k3s.yaml /opt/k3s/config
        chown -R heywoodlh: /opt/k3s
      '';
    in {
      enable = true;
      wantedBy = [ "multi-user.target" ];
      after = [ "k3s.service" ];
      partOf = [ "k3s.service" ];
      description = "Setup k3s config for heywoodlh";
      path = with pkgs; [
        gnugrep
        findutils
        coreutils
      ];
      serviceConfig = {
        Type = "oneshot";
        User = "root";
        ExecStart = "${setupConfig}";
      };
    };
    k3s-remove-failed-admissions = let
      removeFailedPods = pkgs.writeShellScript "k3s-remove-failed-config" ''
      '';
    in {
      enable = true;
      wantedBy = [ "multi-user.target" ];
      after = [ "k3s.service" ];
      partOf = [ "k3s.service" ];
    };

    k3s-fix-dns = let
      corednsConfigmap = pkgs.writeText "" ''
        ---
        kind: ConfigMap
        metadata:
          name: coredns
          namespace: kube-system
        apiVersion: v1
        data:
          Corefile: |
            .:53 {
                errors
                health
                ready
                kubernetes cluster.local in-addr.arpa ip6.arpa {
                  pods insecure
                  fallthrough in-addr.arpa ip6.arpa
                }
                hosts /etc/coredns/NodeHosts {
                  ttl 60
                  reload 15s
                  fallthrough
                }
                prometheus :9153
                forward . 1.1.1.1 1.0.0.1
                cache 30
                loop
                reload
                loadbalance
            }

          NodeHosts: |
            192.168.1.22 homelab
      '';
      fixDns = pkgs.writeShellScript "k3s-fix-dns" ''
        until kubectl get nodes/homelab | grep -q Ready
        do
            echo "Waiting for node to be Ready"
            sleep 5
        done
        echo "Node is ready, applying CoreDNS configmap"
        kubectl apply -f ${corednsConfigmap}
        echo "Restarting CoreDNS"
        kubectl get -n kube-system pods | grep coredns | awk '{print $1}' | xargs kubectl -n kube-system delete pod
      '';
    in {
      enable = config.networking.hostName == "homelab";
      wantedBy = [ "multi-user.target" ];
      after = [ "k3s.service" ];
      partOf = [ "k3s.service" ];
      description = "Fix for k3s DNS";
      path = with pkgs; [
        kubectl
        gnugrep
        gawk
        findutils
      ];
      environment = {
        KUBECONFIG = "/etc/rancher/k3s/k3s.yaml";
      };
      serviceConfig = {
        Type = "oneshot";
        User = "root";
        ExecStart = "${fixDns}";
      };
    };
  };
  security.pam.loginLimits = [
    {
      domain = "*";
      type = "-";
      item = "nofile";
      value = "9192";
    }
  ];

  home-manager.users.heywoodlh.home.file = {
    ".kube/config".enable = lib.mkForce false;
    ".config/fish/override.fish".text = ''
      functions -e k9s
      functions -e kubectl
      export KUBECONFIG="/opt/k3s/config"
    '';
  };

  virtualisation.docker.enable = true;
}
