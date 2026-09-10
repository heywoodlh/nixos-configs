{ pkgs, kubelib, nixhelm, mkKubeDrv }:
let
  base = kubelib.buildHelmChart {
    name = "istio-base";
    chart = (nixhelm.charts { inherit pkgs; }).istio.base;
    namespace = "istio-system";
    values = { };
  };
  control = kubelib.buildHelmChart {
    name = "istiod";
    chart = (nixhelm.charts { inherit pkgs; }).istio.istiod;
    namespace = "istio-system";
    values.meshConfig.extensionProviders = [{
      name = "crowdsec";
      envoyExtAuthzGrpc = {
        service = "crowdsec-bouncer.crowdsec.svc.cluster.local";
        port = 8080;
      };
    }];
  };
  gateway = kubelib.buildHelmChart {
    name = "plex-gateway";
    chart = (nixhelm.charts { inherit pkgs; }).istio.gateway;
    namespace = "istio-system";
    values = {
      replicaCount = 1;
      autoscaling.enabled = false;
      nodeSelector."kubernetes.io/hostname" = "homelab";
      service = {
        type = "LoadBalancer";
        loadBalancerIP = "192.168.1.22";
        externalTrafficPolicy = "Local";
        annotations = {
          "tailscale.com/expose" = "true";
          "tailscale.com/hostname" = "plex";
          "tailscale.com/tags" = "tag:plex";
        };
        ports = [
          { name = "status-port"; port = 15021; targetPort = 15021; protocol = "TCP"; }
          { name = "plex-https"; port = 32400; targetPort = 32400; nodePort = 32400; protocol = "TCP"; }
        ];
      };
    };
  };
  routing = mkKubeDrv "istio-routing" { src = ./templates/istio.yaml; };
in pkgs.runCommand "istio" { } ''
  cat ${base} ${control} ${gateway} ${routing} > $out
''
