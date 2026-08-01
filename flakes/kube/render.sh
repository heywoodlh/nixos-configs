#!/usr/bin/env bash

root_dir="$( cd -- "$(dirname "$0")" >/dev/null 2>&1 ; pwd -P )"

applications=(
  "actual"
  "android"
  "attic"
  "argo"
  "beeper-bridges"
  "hermes-agent"
  "cloudflared"
  "coredns"
  "coredns-kube-system"
  "crossplane"
  "drawio"
  "duplicati"
  "elastic-cloud-operator"
  "elastic-cloud-elastic-stack"
  "flan-scan"
  "fleetdm"
  "fuse-device-plugin"
  "ersatztv"
  "grafana"
  "hashcat"
  "healthchecks"
  "homepage"
  "home-assistant"
  "homebridge"
  "http-files"
  "immich"
  "immich-machine-learning"
  "iperf"
  "lancache"
  "llama-swap"
  "media"
  "metasploit"
  "meshtastic"
  "minecraft-bedrock"
  "minecraft-java"
  "miniflux"
  "namespaces"
  "nfcapd"
  "ntfy"
  "nuclei"
  "open-webui"
  "palworld"
  "pinchflat"
  "prometheus"
  "protonmail-bridge"
  "redm"
  "rocketchat"
  "rsshub"
  "rustdesk"
  "rustdesk-web"
  "samplicator"
  "scrutiny-proxy"
  "skyrim-together"
  "spindle"
  "silverbullet"
  "syncthing"
  "syslog"
  "tailscale-dns-bridge"
  "tailscale-mullvad-socks-router"
  "tor-socks-proxy"
  "xpipe"
)

set -ex

gen_list=true

error="false"
if [[ -n "${1}" ]]
then
    applications=("${1}")
    gen_list=false
else
    echo "" > ${root_dir}/manifests/apps.yaml
fi

for app in "${applications[@]}"
do
    #nix build --option substitute false "${root_dir}#${app}"
    nix build "${root_dir}#${app}" || error="true"
    cp ./result "${root_dir}/manifests/${app}.yaml" || error="true" # Copy file instead of using symlink
    chmod 644 "${root_dir}/manifests/${app}.yaml" || error="true"

    if [[ "${gen_list}" == true ]]
    then
cat >> ${root_dir}/manifests/apps.yaml << EOL || error="true"
---
apiVersion: argoproj.io/v1alpha1
kind: Application
metadata:
  name: ${app}
  namespace: argo
spec:
  destination:
    server: https://kubernetes.default.svc
    namespace: argo
  source:
    repoURL: https://knot1.tangled.sh/did:plc:ycnss4fntzi3rjuueb7loq3x/nixos-configs
    targetRevision: HEAD
    path: flakes/kube/manifests
    directory:
      include: "${app}.yaml"
  project: default
  syncPolicy:
    automated:
      prune: true
      selfHeal: true
EOL
    fi
    # Halt and restore if failure encountered
    if [[ "${error}" == "true" ]]
    then
      printf "Error processing app \"%s\", halting execution and restoring %s/manifests" "${app}" "${root_dir}"
      git restore "${root_dir}/manifests"
      exit 1
    fi
done
