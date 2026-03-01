{
  description = "heywoodlh kubernetes flake";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    nixpkgs-old.url = "github:NixOS/nixpkgs/nixos-24.05"; # For deprecated substituteAll function
    flake-utils.url = "github:numtide/flake-utils";
    fish-flake = {
      url = ../fish;
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.flake-utils.follows = "flake-utils";
    };
    cloudflared-helm = {
      url = "github:cloudflare/helm-charts";
      flake = false;
    };
    nfs-helm = {
      url = "github:kubernetes-sigs/nfs-subdir-external-provisioner";
      flake = false;
    };
    nix-kube-generators.url = "github:farcaller/nix-kube-generators";
    nixhelm = {
      url = "github:nix-community/nixhelm";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.flake-utils.follows = "flake-utils";
      inputs.nix-kube-generators.follows = "nix-kube-generators";
      inputs.poetry2nix.inputs = {
        flake-utils.follows = "nixhelm/flake-utils";
        systems.follows = "nixhelm/flake-utils/systems";
      };
    };
    tailscale = {
      url = "github:tailscale/tailscale";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.systems.follows = "flake-utils/systems";
    };
    truecharts-helm = {
      url = "github:truecharts/charts";
      flake = false;
    };
    open-webui = {
      url = "github:open-webui/open-webui";
      flake = false;
    };
    coredns = {
      url = "github:coredns/helm";
      flake = false;
    };
    wazuh = {
      url = "github:wazuh/wazuh-kubernetes/v4.9.0";
      flake = false;
    };
    crossplane = {
      url = "github:upbound/universal-crossplane/release-1.18";
      flake = false;
    };
    elastic-cloud = {
      url = "github:elastic/cloud-on-k8s/v3.0.0";
      flake = false;
    };
    krew2nix = {
      url = "github:eigengrau/krew2nix";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.flake-utils.follows = "flake-utils";
    };
    kasmweb = {
      url = "github:kasmtech/kasm-helm/release/1.16.0";
      flake = false;
    };
  };

  outputs = inputs @ {
    self,
    nixpkgs,
    nixpkgs-old,
    flake-utils,
    nfs-helm,
    nix-kube-generators,
    nixhelm,
    tailscale,
    cloudflared-helm,
    truecharts-helm,
    open-webui,
    coredns,
    wazuh,
    crossplane,
    elastic-cloud,
    krew2nix,
    kasmweb,
    fish-flake,
  }:
    flake-utils.lib.eachDefaultSystem (system: let
      pkgs = import nixpkgs {
        inherit system;
        config.allowUnfree = true;
      };
      oldpkgs = import nixpkgs-old {
        inherit system;
        config.allowUnfree = true;
      };
      mkKubeDrv = pkgName: args: let
        yaml = oldpkgs.substituteAll args;
      in builtins.derivation {
        name = pkgName;
        inherit system;
        builder = "${pkgs.bash}/bin/bash";
        args = [
          "-c"
          ''
          ${pkgs.coreutils}/bin/cp ${yaml} $out
          ''
        ];
      };
      kubelib = nix-kube-generators.lib { inherit pkgs; };
      ts-env = pkgs.writeShellScriptBin "tsenv" ''
        TS_CLIENT_ID="$(op-wrapper.sh read 'op://Personal/odnjqovwnyxpltktqd3a5yzqpy/password')"
        TS_SECRET="$(op-wrapper.sh read 'op://Personal/qv3mc3sgnpgw6yfuxtgf6xseou/password')"

        echo export TS_CLIENT_ID="$TS_CLIENT_ID"
        echo export TS_SECRET="$TS_SECRET"
      '';
      op-wrapper = fish-flake.packages.${system}.op-wrapper;
      talos-wrapper = pkgs.writeShellScriptBin "talosctl" ''
        mkdir -p ~/tmp/talos
        item="op://kubernetes/h6d3bdi7yx2kvrk64u2lolva74"

        [[ -e ~/tmp/talos/controlplane.yaml ]] || ${op-wrapper}/bin/op read "$item/controlplane.yaml" > ~/tmp/talos/controlplane.yaml
        [[ -e ~/tmp/talos/talosconfig ]] || ${op-wrapper}/bin/op read "$item/talosconfig" > ~/tmp/talos/talosconfig
        [[ -e ~/tmp/talos/worker.yaml ]] || ${op-wrapper}/bin/op read "$item/worker.yaml" > ~/tmp/talos/worker.yaml
        [[ -e ~/tmp/talos/storage.yaml ]] || ${op-wrapper}/bin/op read "$item/storage.yaml" > ~/tmp/talos/storage.yaml

        ${pkgs.talosctl}/bin/talosctl --talosconfig ~/tmp/talos/talosconfig $@
      '';
      onepassworditem = pkgs.writers.writePython3Bin "onepassitem.py" { libraries = [ pkgs.python3Packages.PyGithub ]; } ''
      import argparse

      parser = argparse.ArgumentParser(description="Create a OnePasswordItem")
      parser.add_argument("--name", help="Name of secret", required=True)
      parser.add_argument("--namespace", help="Namespace", required=True)
      parser.add_argument("--itemPath", help="Path of item", required=True)

      args = parser.parse_args()

      item = """
      ---
      apiVersion: onepassword.com/v1
      kind: OnePasswordItem
      metadata:
        name: "{0}"
        namespace: "{1}"
      spec:
        itemPath: "{2}"
      """

      print(item.format(args.name, args.namespace, args.itemPath))
      '';
    in {
      packages = {
        "1password-connect" = (kubelib.buildHelmChart {
          name = "1password-connect";
          chart = (nixhelm.charts { inherit pkgs; })."1password".connect;
          namespace = "kube-system";
          values = {
            # op connect server create k3s-cluster --vaults Kubernetes && mv 1password-credentials.json /tmp/
            connect.credentials = builtins.readFile /tmp/1password-credentials.json;
            operator = {
              create = true;
              # op connect token create --server k3s-cluster --vault Kubernetes k3s-cluster > /tmp/token.txt
              token.value = builtins.readFile /tmp/token.txt;
              # Automatically restart the operator if secrets are updated
              autoRestart = true;
            };
          };
        });
        "1password-item" = onepassworditem;
        arma-reforger = mkKubeDrv "arma-reforger" {
          src = ./templates/arma-reforger.yaml;
          namespace = "gaming";
          replicas = 1;
          hostfolder = "/media/data-ssd/games/arma-reforger";
          nodename = "homelab";
          address = "100.77.128.95";
        };
        attic = mkKubeDrv "attic" {
          src = ./templates/attic.yaml;
          namespace = "default";
          replicas = 1;
          image = "docker.io/heywoodlh/attic:47752427561f1c34debb16728a210d378f0ece36";
          hostfolder = "/media/data-ssd/attic";
        };
        actual = mkKubeDrv "actual" {
          src = ./templates/actual.yaml;
          namespace = "default";
          replicas = 1;
          image = "docker.io/actualbudget/actual-server:25.12.0-alpine";
          hostfolder = "/media/data-ssd/actual";
        };
        # After applying this, run the following: `kubectl apply -f ./kubectl/argo-nix-configmap.yaml`
        argo = (kubelib.buildHelmChart {
          name = "argo";
          chart = (nixhelm.charts { inherit pkgs; }).argoproj.argo-cd;
          namespace = "argo";
          values = {
            repoServer = {
              volumes = [
                {
                  name = "nix-cmp-config";
                  configMap = { name = "nix-cmp-config"; };
                }
                {
                  name = "nix-cmp-tmp";
                  emptyDir = { };
                }
                {
                  name = "nix-cmp-nix";
                  emptyDir = { };
                }
                {
                  name = "nix-cmp-home";
                  emptyDir = { };
                }
              ];
              initContainers = [
                {
                  name = "nix-bootstrap";
                  command = [ "sh" "-c" "cp -a /nix/* /nixvol && chown -R 999 /nixvol/*" ];
                  image = "docker.io/nixos/nix:latest";
                  imagePullPolicy = "Always";
                  volumeMounts = [
                    {
                      mountPath = "/nixvol";
                      name = "nix-cmp-nix";
                    }
                  ];
              }];
              extraContainers = [
                {
                  name = "nix-cmp-plugin";
                  command = [ "/var/run/argocd/argocd-cmp-server" ];
                  image = "docker.io/nixos/nix:latest";
                  imagePullPolicy = "Never";
                  securityContext = {
                    runAsNonRoot = true;
                    runAsUser = 999;
                  };
                  volumeMounts = [
                    {
                      mountPath = "/var/run/argocd";
                      name = "var-files";
                    }
                    {
                      mountPath = "/home/argocd/cmp-server/plugins";
                      name = "plugins";
                    }
                    {
                      mountPath = "/home/argocd/cmp-server/config/plugin.yaml";
                      subPath = "plugin.yaml";
                      name = "nix-cmp-config";
                    }
                    {
                      mountPath = "/etc/passwd";
                      subPath = "passwd";
                      name = "nix-cmp-config";
                    }
                    {
                      mountPath = "/etc/nix/nix.conf";
                      subPath = "nix.conf";
                      name = "nix-cmp-config";
                    }
                    {
                      mountPath = "/tmp";
                      name = "nix-cmp-tmp";
                    }
                    {
                      mountPath = "/nix";
                      name = "nix-cmp-nix";
                    }
                    {
                      mountPath = "/home/nix";
                      name = "nix-cmp-home";
                    }
                  ];
                }
              ];
            };
          };
        });
        atuin = mkKubeDrv "atuin" {
          src = ./templates/atuin.yaml;
          namespace = "default";
          replicas = 1;
          image = "ghcr.io/atuinsh/atuin:v18.10.0";
          postgres_image = "docker.io/postgres:14";
        };
        beeper-bridges = mkKubeDrv "beeper-bridges" {
          src = ./templates/beeper-bridges.yaml;
          namespace = "messaging";
          replicas = 1;
          image = "ghcr.io/beeper/bridge-manager:8ff78f238554b359e24eb196649eaea0179a700b";
          hostfolder = "/media/data-ssd/beeper";
        };
        # Run the following before deploying:
        # nix run .#1password-item -- --name dev-password --namespace default --itemPath "vaults/kubernetes/items/boofeqmvt6vmcdqsyzczhiwqre" | kubectl apply -f -
        dev = mkKubeDrv "dev" {
          src = ./templates/dev.yaml;
          namespace = "default";
          replicas = 1;
          image = "docker.io/heywoodlh/dev:2026_01_snapshot";
        };
        cloudflared = mkKubeDrv "cloudflared" {
          src = ./templates/cloudflared.yaml;
          namespace = "cloudflared";
          image = "docker.io/cloudflare/cloudflared:2025.11.1";
          replicas = 2;
        };
        cloudtube = mkKubeDrv "cloudtube" {
          src = ./templates/cloudtube.yaml;
          namespace = "default";
          image = "docker.io/heywoodlh/cloudtube:2024_12";
          second_image = "docker.io/heywoodlh/second:2023_12";
          replicas = 1;
        };
        coder = mkKubeDrv "coder" {
          src = ./templates/coder.yaml;
          namespace = "coder";
          version = "2.8.3";
          image = "ghcr.io/coder/coder:v2.29.0";
          access_url = "https://coder.heywoodlh.io";
          replicas = "1";
          port = "80";
          postgres_version = "16.1.0";
          postgres_image = "docker.io/bitnami/postgresql:16.6.0";
          postgres_replicas = "1";
          postgres_storage_class = "local-path";
        };
        comfyui = mkKubeDrv "comfyui" {
          src = ./templates/comfyui.yaml;
          namespace = "default";
          image = "ghcr.io/lecode-official/comfyui-docker:latest";
          hostfolder = "/media/data-ssd/comfyui";
        };
        coredns = mkKubeDrv "coredns" {
          src = ./templates/coredns.yaml;
          tailnet = "barn-banana.ts.net";
          namespace = "coredns";
          image = "docker.io/coredns/coredns:1.13.1";
          replicas = "1";
        };
        coredns-kube-system = mkKubeDrv "coredns-kube-system" {
          src = ./templates/kube-system-coredns.yaml;
          tailnet = "barn-banana.ts.net";
        };
        "crossplane" = (kubelib.buildHelmChart {
          name = "crossplane";
          chart = "${crossplane}/cluster/charts/universal-crossplane";
          namespace = "upbound-system";
          values = {};
        });
        drawio = mkKubeDrv "drawio" {
          src = ./templates/draw-io.yaml;
          namespace = "drawio";
          tag = "23.0.0";
          port = "80";
          replicas = "1";
        };
        duplicati = mkKubeDrv "duplicati" {
          src = ./templates/duplicati.yaml;
          namespace = "default";
          image = "docker.io/linuxserver/duplicati:2.2.0";
          hostfolder = "/media/data-ssd/duplicati";
          nodename = "homelab";
        };
        elastic-cloud-operator = (kubelib.buildHelmChart {
          name = "elastic-cloud-operator";
          chart = "${elastic-cloud}/deploy/eck-operator";
          namespace = "monitoring";
          values.image.tag = "3.0.0";
        });
        elastic-cloud-elastic-stack = mkKubeDrv "elastic-stack" {
          src = ./templates/elastic-stack.yaml;
          namespace = "monitoring";
          version = "8.17.5";
          elasticsearch_nodecount = 1;
          kibana_nodecount = 1;
          logstash_nodecount = 1;
          hostfolder = "/media/data-ssd/elastic";
          nodename = "homelab";
        };
        ersatztv = mkKubeDrv "ersatztv" {
          src = ./templates/ersatztv.yaml;
          namespace = "media";
          image = "ghcr.io/ersatztv/ersatztv:latest";
          replicas = 1;
          hostfolder = "/media/data-ssd/ersatztv";
          hostmediafolder = "/media/home-media";
          nodename = "homelab";
        };
        flan-scan = mkKubeDrv "flan-scan" {
          src = ./templates/flan-scan.yaml;
          namespace = "monitoring";
          image = "docker.io/heywoodlh/flan-scan:2025_11";
          http_image = "docker.io/heywoodlh/http-files:v2.10.2";
          hostfolder = "/media/data-ssd/flan-scan";
          replicas = 1;
        };
        fleetdm = mkKubeDrv "fleetdm" {
          src = ./templates/fleetdm.yaml;
          namespace = "monitoring";
          image = "docker.io/fleetdm/fleet:v4.78.1";
          mysql_image = "docker.io/mysql:8.4.7";
          redis_image = "docker.io/redis:8.0-M02-alpine3.21";
          replicas = 1;
          logs_hostfolder = "/media/data-ssd/syslog/fleet";
        };
        foldingathome = mkKubeDrv "foldingathome" {
          src = ./templates/foldingathome.yaml;
          namespace = "foldingathome";
          image = "lscr.io/linuxserver/foldingathome:8.4.9";
          hostfolder = "/media/data-ssd/foldingathome";
          replicas = 1;
        };
        gomuks = mkKubeDrv "gomuks" {
          src = ./templates/gomuks.yaml;
          namespace = "default";
          image = "dock.mau.dev/tulir/gomuks:latest";
          replicas = 1;
        };
        grafana = mkKubeDrv "grafana" {
          src = ./templates/grafana.yaml;
          namespace = "monitoring";
          image = "docker.io/grafana/grafana:12.4.0";
          storageclass = "local-path";
        };
        hashcat = mkKubeDrv "hashcat" {
          src = ./templates/hashcat.yaml;
          namespace = "security";
          image = "docker.io/ubuntu:24.10";
        };
        hashtopolis = mkKubeDrv "hashtopolis" {
          src = ./templates/hashtopolis.yaml;
          namespace = "security";
          frontend_image = "docker.io/hashtopolis/frontend:latest";
          backend_image = "docker.io/hashtopolis/backend:latest";
          agent_image = "docker.io/hashtopolis/agent:master";
          mysql_image = "docker.io/mysql:8.4";
          hostfolder = "/media/data-ssd/hashtopolis";
          nodename = "homelab";
        };
        healthchecks = mkKubeDrv "healthchecks" {
          src = ./templates/healthchecks.yaml;
          namespace = "monitoring";
          image = "docker.io/curlimages/curl:8.17.0";
        };
        heralding = mkKubeDrv "heralding" {
          src = ./templates/heralding.yaml;
          namespace = "default";
          image = "docker.io/heywoodlh/heralding:1.0.7";
          replicas = 1;
        };
        home-assistant = mkKubeDrv "home-assistant" {
          src = ./templates/home-assistant.yaml;
          namespace = "default";
          timezone = "America/Denver";
          image = "ghcr.io/home-assistant/home-assistant:2025.12.0";
          matter_image = "ghcr.io/home-assistant-libs/python-matter-server:8.1";
          go2rtc_image = "docker.io/alexxit/go2rtc:1.9.14";
          frigate_image = "ghcr.io/blakeblackshear/frigate:stable";
          eufy_image = "docker.io/bropat/eufy-security-ws:1.9";
          port = 80;
          replicas = 1;
          nodename = "homelab";
          hostfolder = "/media/data-ssd/home-assistant";
        };
        homebridge = mkKubeDrv "homebridge" {
          src = ./templates/homebridge.yaml;
          namespace = "default";
          image = "docker.io/homebridge/homebridge:latest";
          nodename = "homelab";
          hostfolder = "/media/data-ssd/homebridge";
        };
        homepage = mkKubeDrv "homepage" {
          src = ./templates/homepage.yaml;
          image = "ghcr.io/gethomepage/homepage:v1.7.0";
          namespace = "default";
        };
        http-files = mkKubeDrv "http-files" {
          src = ./templates/http-files.yaml;
          namespace = "default";
          image = "docker.io/heywoodlh/http-files:v2.10.2";
          replicas = 1;
        };
        immich = mkKubeDrv "immich" rec {
          src = ./templates/immich.yaml;
          namespace = "default";
          version = "v2";
          timezone = "America/Denver";
          image = "ghcr.io/immich-app/immich-server:${version}";
          postgres_image = "ghcr.io/immich-app/postgres:14-vectorchord0.4.3-pgvectors0.2.0@sha256:bcf63357191b76a916ae5eb93464d65c07511da41e3bf7a8416db519b40b1c23";
          valkey_image = "docker.io/valkey/valkey:8@sha256:81db6d39e1bba3b3ff32bd3a1b19a6d69690f94a3954ec131277b9a26b95b3aa";
          replicas = 1;
          hostfolder = "/media/data-ssd/immich";
          datafolder = "/media/data_pool/immich/data";
        };
        immich-machine-learning = mkKubeDrv "immich-machine-learning" {
          src = ./templates/immich-ml.yaml;
          namespace = "default";
          timezone = "America/Denver";
          image = "ghcr.io/immich-app/immich-machine-learning:v2.3.1-openvino";
          replicas = 1;
          hostfolder = "/media/data-ssd/immich-ml";
        };
        intel-device-plugin = mkKubeDrv "http-files" {
          src = ./templates/intel-device-plugin.yaml;
          namespace = "default";
          version = "v0.34.0";
          replicas = 1;
        };
        iperf = mkKubeDrv "iperf" {
          src = ./templates/iperf3.yaml;
          namespace = "default";
          image = "docker.io/heywoodlh/iperf3:3.16-r0";
          replicas = 1;
        };
        jellyfin = mkKubeDrv "jellyfin" {
          src = ./templates/jellyfin.yaml;
          namespace = "default";
          tag = "20231213.1-unstable";
          replicas = 1;
        };
        # Create ns first: kubectl create ns kasmweb
        "kasmweb" = (kubelib.buildHelmChart {
          name = "kasmweb";
          chart = "${kasmweb}/kasm-single-zone";
          namespace = "kasmweb";
          values = {
            global = {
              namespace = "kasmweb";
              hostname = "kasmweb";
              altHostnames = [
                "kasm-proxy.kasmweb.svc.cluster.local"
                "kasmweb.heywoodlh.io"
              ];
            };
          };
        });
        kubevirt = mkKubeDrv "kubevirt" {
          src = ./templates/kubevirt.yaml;
          version = "v1.4.0";
        };
        # For whatever reason, Tailscale's 'tailscale.com/tailnet-ip' doesn't seem to work
        # Manually set the IPs in the Tailscale admin UI
        lancache = mkKubeDrv "lancache" {
          src = ./templates/lancache.yaml;
          namespace = "default";
          dns_image = "docker.io/heywoodlh/lancache-dns:latest";
          dns_upstream = "10.43.9.152"; # use coredns, which will work with tailscale and kubernetes
          dns_ip = "100.65.18.5";
          cache_ip = "100.65.18.10";
          cache_disk_size = "1000g";
          cache_index_size = "500m";
          cache_max_age = "3650d";
          cache_hostDir = "/media/data-ssd/lancache/";
          cache_image = "docker.io/lancachenet/monolithic:latest";
          cache_generic = "true";
          timezone = "America/Denver";
          replicas = 1;
          nodename = "homelab";
        };
        llama = mkKubeDrv "llama" {
          src = ./templates/llama.yaml;
          namespace = "default";
          image = "ghcr.io/mostlygeek/llama-swap:intel";
          hostfolder = "/media/data-ssd/llama";
        };
        longhorn = mkKubeDrv "longhorn" {
          src = ./templates/longhorn.yaml;
          namespace = "longhorn-system";
          version = "1.5.5";
        };
        media = mkKubeDrv "media" {
          src = ./templates/media.yaml;
          namespace = "media";
          replicas = 1;
          media_uid = "995";
          plex_image = "docker.io/linuxserver/plex:1.42.2";
          plex_hostfolder = "/media/config/services/plex";
          radarr_image = "docker.io/linuxserver/radarr:5.28.1-nightly";
          radarr_hostfolder = "/media/config/services/radarr";
          sonarr_image = "docker.io/linuxserver/sonarr:4.0.16-develop";
          sonarr_hostfolder = "/media/config/services/sonarr";
          lidarr_image = "ghcr.io/hotio/lidarr:pr-plugins";
          lidarr_hostfolder = "/media/config/services/lidarr";
          readarr_image = "docker.io/linuxserver/readarr:0.4.19-nightly";
          readarr_hostfolder = "/media/config/services/readarr";
          sabnzbd_image = "docker.io/linuxserver/sabnzbd:4.5.5";
          sabnzbd_hostfolder = "/media/config/services/sabnzbd";
          tautulli_image = "docker.io/tautulli/tautulli:v2.16.0";
          tautulli_hostfolder = "/media/config/services/tautulli/config";
          qbittorrent_image = "docker.io/linuxserver/qbittorrent:5.1.4";
          qbittorrent_hostfolder = "/media/config/services/qbittorrent";
          openaudible_image = "docker.io/openaudible/openaudible:latest";
          openaudible_hostfolder = "/media/config/services/openaudible";
          media_hostfolder = "/media/home-media";
          nodename = "homelab";
        };
        meshtastic = mkKubeDrv "meshtastic" {
          src = ./templates/meshtastic.yaml;
          namespace = "default";
          image = "docker.io/heywoodlh/contact:8fd48c5e5fa60043d443ecf038df4e28167bec13";
          usb = "/dev/ttyUSB1";
        };
        metrics-server = mkKubeDrv "metrics-server" {
          src = ./templates/metrics-server.yaml;
          image = "registry.k8s.io/metrics-server/metrics-server:v0.8.0";
        };
        metube = mkKubeDrv "metube" {
          src = ./templates/metube.yaml;
          namespace = "default";
          image = "ghcr.io/alexta69/metube:2024-12-04";
          replicas = 1;
        };
        minecraft-bedrock = mkKubeDrv "minecraft-bedrock" {
          src = ./templates/minecraft-bedrock.yaml;
          namespace = "gaming";
          image = "ghcr.io/dmedina559/bedrock-server-manager:stable";
          nodename = "homelab";
          hostfolder = "/media/data-ssd/minecraft";
        };
        minecraft-java = mkKubeDrv "minecraft-bedrock" {
          src = ./templates/minecraft-java.yaml;
          namespace = "gaming";
          image = "docker.io/itzg/minecraft-server:latest";
          nodename = "homelab";
          hostfolder = "/media/data-ssd/minecraft-java";
        };
        miniflux = mkKubeDrv "miniflux" {
          src = ./templates/miniflux.yaml;
          namespace = "default";
          image = "docker.io/miniflux/miniflux:2.2.14";
          postgres_image = "docker.io/postgres:15.15";
          postgres_replicas = 1;
          nodename = "homelab";
          hostfolder = "/opt/miniflux";
          replicas = 1;
        };
        motioneye = mkKubeDrv "motioneye" {
          src = ./templates/motioneye.yaml;
          namespace = "default";
          storageclass = "local-path";
          tag = "dev-amd64";
          replicas = 1;
          port = 80;
          nodename = "homelab";
        };
        namespaces = mkKubeDrv "namespaces" {
          src = ./templates/namespaces.yaml;
        };
        nfcapd = mkKubeDrv "nfcapd" {
          src = ./templates/nfcapd.yaml;
          namespace = "monitoring";
          image = "docker.io/heywoodlh/nfdump:1.7.6";
          hostfolder = "/media/data-ssd/flows";
        };
        nfs-kube = (kubelib.buildHelmChart {
          name = "nfs-kube";
          chart = "${nfs-helm}/charts/nfs-subdir-external-provisioner";
          namespace = "default";
          values = {
            image.tag = "v4.0.2";
            nfs = {
              server = "100.107.238.93";
              path = "/media/virtual-machines/kube";
            };
            storageClass = {
              provisionerName = "nfs-kube";
              name = "nfs-kube";
              reclaimPolicy = "Retain";
            };
            podAnnotations = {
              "tailscale.com/tags" = "tag:nfs-client";
              "tailscale.com/expose" = "true";
            };
            nodeSelector = {
              "env" = "home";
            };
          };
        });
        ntfy = mkKubeDrv "ntfy" {
          src = ./templates/ntfy.yaml;
          namespace = "default";
          image = "docker.io/binwiederhier/ntfy:v2.15.0";
          base_url = "http://ntfy.barn-banana.ts.net";
          timezone = "America/Denver";
          replicas = 1;
        };
        nuclei = mkKubeDrv "nuclei" {
          src = ./templates/nuclei.yaml;
          namespace = "nuclei";
          image = "docker.io/heywoodlh/nuclei:v3.5.1";
          interactsh_image = "docker.io/projectdiscovery/interactsh-server:v1.2.4";
          httpd_image = "docker.io/httpd:2.4.66";
          replicas = 1;
        };
        ollama = mkKubeDrv "ollama" {
          src = ./templates/ollama.yaml;
          namespace = "default";
          # TODO switch back to whyvl/ollama-vulkan when issue 26 is fixed
          #image = "docker.io/mthreads/ollama:0.11.5-rc2-23-g52fe8ce-vulkan-amd64";
          image = "docker.io/grinco/ollama-amd-apu:vulkan";
          hostfolder = "/media/data-ssd/ollama";
        };
        open-webui = mkKubeDrv "open-webui" {
          src = ./templates/open-webui.yaml;
          namespace = "open-webui";
          webui_image = "ghcr.io/open-webui/open-webui:0.6.41";
          ollama_image = "docker.io/ollama/ollama:0.13.1";
          hostfolder = "/opt/open-webui";
        };
        palworld = mkKubeDrv "palworld" {
          src = ./templates/palworld.yaml;
          namespace = "palworld";
          image = "docker.io/thijsvanloef/palworld-server-docker:dev";
          hostfolder = "/opt/palworld";
        };
        pinchflat = mkKubeDrv "pinchflat" {
          src = ./templates/pinchflat.yaml;
          namespace = "media";
          image = "keglin/pinchflat:latest";
          replicas = 1;
          hostfolder = "/media/data-ssd/pinchflat";
          hostmediafolder = "/media/home-media/disk3/youtube";
          nodename = "homelab";
        };
        # Ensure to deploy prometheus-blackbox-exporter first
        prometheus = (kubelib.buildHelmChart {
          name = "prometheus";
          chart = (nixhelm.charts { inherit pkgs; }).prometheus-community.prometheus;
          namespace = "monitoring";
          values = {
            server = {
              image = {
                repository = "quay.io/prometheus/prometheus";
                tag = "v3.8.0";
              };
              extraFlags = [
                "storage.tsdb.wal-compression"
              ];
              resources = {
                limits = {
                  cpu = "2";
                  memory = "8192Mi";
                };
                requests = {
                  cpu = "500m";
                  memory = "1024Mi";
                };
              };
            };
            alertmanager.enabled = false;
            kube-state-metrics.enabled = false;
            prometheus-node-exporter.enabled = false;
            prometheus-pushgateway.enabled = false;
            extraScrapeConfigs = ''
              - job_name: "metrics-server"
                scrape_interval: 5m
                static_configs:
                - targets:
                  - metrics-server.kube-system.svc:443
                tls_config:
                  insecure_skip_verify: true

              - job_name: "node"
                scrape_interval: 5m
                static_configs:
                - targets:
                  - homelab.barn-banana.ts.net:9100
                  - spencer-router.barn-banana.ts.net:9100
                  - yasmin-router.barn-banana.ts.net:9100
                  - arlene-router.barn-banana.ts.net:9100
            '';
          };
        });
        prometheus-blackbox-exporter = (kubelib.buildHelmChart {
          name = "prometheus";
          chart = (nixhelm.charts { inherit pkgs; }).prometheus-community.prometheus-blackbox-exporter;
          namespace = "monitoring";
          values = {
            image = {
              registry = "quay.io";
              repository = "prometheus/blackbox-exporter";
              tag = "v0.25.0";
            };
          };
        });
        protonmail-bridge = mkKubeDrv "protonmail-bridge" {
          src = ./templates/protonmail-bridge.yaml;
          namespace = "default";
          image = "docker.io/shenxn/protonmail-bridge:3.19.0-1";
          ferroxide_image = "docker.io/heywoodlh/ferroxide:2026_01";
          nodename = "homelab";
          hostfolder = "/opt/protonmail-bridge";
          replicas = 1;
        };
        redlib = mkKubeDrv "redlib" {
          src = ./templates/redlib.yaml;
          namespace = "default";
          port = 80;
          replicas = 1;
          image = "quay.io/redlib/redlib:latest";
        };
        redm = mkKubeDrv "redm" {
          src = ./templates/redm.yaml;
          namespace = "gaming";
          replicas = 1;
          image = "docker.io/routmoute/fxserver:recommended";
          mysql_image = "docker.io/mariadb:10.11.15";
          hostfolder = "/media/data-ssd/redm";
          nodename = "homelab";
        };
        regexr = mkKubeDrv "regexr" {
          src = ./templates/regexr.yaml;
          namespace = "regexr";
          image = "docker.io/heywoodlh/regexr:1e38271";
          replicas = 1;
        };
        retroarcher = mkKubeDrv "retroarcher" {
          src = ./templates/retroarcher.yaml;
          namespace = "default";
          image = "docker.io/lizardbyte/retroarcher:v2024.922.10155";
          nodename = "homelab";
          hostfolder = "/opt/retroarcher";
          replicas = 1;
        };
        rsshub = mkKubeDrv "rsshub" {
          src = ./templates/rsshub.yaml;
          namespace = "default";
          replicas = 1;
          image = "docker.io/diygod/rsshub:2025-02-19";
          browserless_image = "docker.io/browserless/chrome:1.61-puppeteer-13.1.3";
          browserless_replicas = 1;
          redis_image = "docker.io/redis:7.4.7";
          redis_replicas = 1;
          nodename = "homelab";
          hostfolder = "/opt/rsshub";
        };
        rustdesk = mkKubeDrv "rustdesk" {
          src = ./templates/rustdesk.yaml;
          namespace = "default";
          image = "docker.io/rustdesk/rustdesk-server:1.1.10-3";
          nodename = "homelab";
          hostfolder = "/opt/rustdesk";
          replicas = 1;
        };
        rustdesk-web = mkKubeDrv "rustdesk-web" {
          src = ./templates/rustdesk-web.yaml;
          namespace = "default";
          image = "docker.io/heywoodlh/rustdesk-web:1.4.4";
          replicas = 1;
        };
        samplicator = mkKubeDrv "samplicator" {
          src = ./templates/samplicator.yaml;
          namespace = "monitoring";
          image = "docker.io/heywoodlh/samplicator:ceeb1d2-2025_04";
          kubectl_image = "docker.io/heywoodlh/kubectl:v1.34.2";
          replicas = 1;
        };
        silverbullet = mkKubeDrv "silverbullet" {
          src = ./templates/silverbullet.yaml;
          namespace = "docs";
          nodename = "homelab";
          image = "ghcr.io/silverbulletmd/silverbullet:v2";
          replicas = 1;
        };
        skyrim-together = mkKubeDrv "skyrim-together" {
          src = ./templates/skyrim-together.yaml;
          namespace = "gaming";
          replicas = 1;
          image = "docker.io/tiltedphoques/st-reborn-server:v1.8.0";
          hostfolder = "/media/data-ssd/st-server";
        };
        sons-of-the-forest = mkKubeDrv "sons-of-the-forest" {
          src = ./templates/sons-of-the-forest.yaml;
          namespace = "theforest";
          image = "docker.io/jammsen/sons-of-the-forest-dedicated-server:latest";
          hostfolder = "/media/data-ssd/theforest";
        };
        squid = mkKubeDrv "squid" {
          src = ./templates/squid.yaml;
          namespace = "default";
          image = "docker.io/heywoodlh/squid:6.13";
          nodename = "homelab";
          hostfolder = "/opt/squid";
          replicas = 1;
        };
        syncthing = mkKubeDrv "syncthing" {
          src = ./templates/syncthing.yaml;
          namespace = "syncthing";
          nodename = "homelab";
          hostfolder = "/opt/syncthing";
          image = "docker.io/syncthing/syncthing:1.30.0";
          replicas = 1;
        };
        syslog = mkKubeDrv "syslog" {
          src = ./templates/syslog.yaml;
          namespace = "monitoring";
          hostfolder = "/media/data-ssd/syslog";
          image = "docker.io/linuxserver/syslog-ng:4.8.3";
          logbash_image = "docker.io/heywoodlh/logbash:e1d594e";
          lnav_image = "docker.io/heywoodlh/lnav:35c17f9";
          replicas = 1;
        };
        # Update nixhelm input for updates
        # Setup secret with this command:
        # nix run .#1password-item -- --name operator-oauth --namespace tailscale --itemPath "vaults/Kubernetes/items/bwmt642lsbd5drsjcrxxnljkku" | kubectl apply -f -
        "tailscale-operator" = (kubelib.buildHelmChart {
          name = "tailscale-operator";
          chart = (nixhelm.charts { inherit pkgs; })."tailscale".tailscale-operator;
          namespace = "tailscale";
          values = {};
        });
        tailscale-dns-bridge = mkKubeDrv "tailscale-dns-bridge" {
          src = ./templates/tailscale-dns-bridge.yaml;
          namespace = "default";
          image = "docker.io/heywoodlh/tailscale-dns-bridge:1.90.9";
          replicas = 1;
          hostfolder = "/opt/tailscale-dns-bridge";
          nodename = "homelab";
        };
        tor-socks-proxy = mkKubeDrv "tor-socks-proxy" {
          src = ./templates/tor-socks-proxy.yaml;
          namespace = "default";
          image = "docker.io/heywoodlh/tor-socks-proxy:0.4.8.21";
          replicas = 1;
        };
        uptime = mkKubeDrv "uptime" {
          src = ./templates/uptime.yaml;
          namespace = "monitoring";
          replicas = 1;
          image = "docker.io/heywoodlh/bash-uptime:0.0.4";
          ntfy_url = "http://ntfy.default/uptime-notifications";
        };
        valheim = mkKubeDrv "valheim" {
          src = ./templates/valheim.yaml;
          namespace = "gaming";
          image = "docker.io/lloesche/valheim-server:latest";
          nodename = "homelab";
          hostfolder = "/media/data-ssd/valheim";
        };
        # Copy certs first: `scp -r homelab:/opt/wazuh/certs /tmp/certs`
        # Then build with: `nix build .#wazuh --impure`
        wazuh = let
          certs = /tmp/certs;
          finalWazuh = pkgs.stdenv.mkDerivation {
            name = "wazuh-with-certs";
            dontUnpack = true;
            buildPhase = ''
              mkdir -p ./kustomize/wazuh/wazuh-src/wazuh/certs
              cp -rn ${certs}/* ./kustomize/wazuh/wazuh-src/wazuh/certs/
              mkdir -p ./kustomize/wazuh
              cp -rn ${self}/kustomize/wazuh/* ./kustomize/wazuh
              cp -rn ${wazuh}/* ./kustomize/wazuh/wazuh-src
              mkdir -p $out
              cp -r * $out
            '';
          };
        in pkgs.stdenv.mkDerivation {
          name = "wazuh";
          dontUnpack = true;
          buildInputs = with pkgs; [
            git
          ];
          buildPhase = ''
            ${pkgs.kubectl}/bin/kubectl kustomize ${finalWazuh}/kustomize/wazuh > $out
          '';
        };
        whishper = mkKubeDrv "whishper" {
          src = ./templates/whishper.yaml;
          namespace = "default";
          replicas = 1;
          image = "docker.io/pluja/whishper:v3.1.4-gpu";
        };
        xpipe = mkKubeDrv "xpipe" {
          src = ./templates/xpipe.yaml;
          namespace = "admin";
          image = "docker.io/heywoodlh/xpipe:latest";
          hostfolder = "/media/data-ssd/xpipe";
          nodename = "homelab";
        };
        # Kubectl wrapper with plugins
        kubectl = let
          kubectl = (krew2nix.packages.${system}.kubectl.withKrewPlugins (plugins: [
            plugins.krew
          ]));
        in pkgs.writeShellScriptBin "kubectl" ''
          PATH="$HOME/.krew/bin:$PATH" ${kubectl}/bin/kubectl "$@";
        '';
      };
      devShell = pkgs.mkShell {
        name = "kubernetes-shell";
        buildInputs = with pkgs; [
          argocd
          gitleaks
          k9s
          kubectl
          kubernetes-helm
          kubevirt
          talos-wrapper
          ts-env
        ];
      };
      formatter = pkgs.alejandra;
    });
}
