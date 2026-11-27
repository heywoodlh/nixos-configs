#!/usr/bin/env bash

root_dir="$( cd -- "$(dirname "$0")" >/dev/null 2>&1 ; pwd -P )"

applications=(
  "actual"
  "attic"
  "beeper-bridges"
  "hermes-agent"
  "cloudflared"
  "cert-manager"
  "crowdsec"
  "coredns"
  "coredns-kube-system"
  "crossplane"
  "davmail"
  "drawio"
  "duplicati"
  "flan-scan"
  "fleetdm"
  "fuse-device-plugin"
  "ersatztv"
  "grafana"
  "harbor"
  "gods-eye-view"
  "healthchecks"
  "homepage"
  "home-assistant"
  "homebridge"
  "http-files"
  "immich"
  "immich-machine-learning"
  "intel-gpu-plugin"
  "istio"
  "iperf"
  "juabsd-forwarder"
  "lancache"
  "lmstudio"
  "media"
  "metasploit"
  "meshtastic"
  "minecraft-bedrock"
  "minecraft-java"
  "miniflux"
  "namespaces"
  "nfcapd"
  "nomad"
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
  "tor-socks-proxy"
  "xpipe"
  "yattee-web"
  "yattee"
)

set -ex

error="false"
if [[ -n "${1}" ]]
then
    applications=("${1}")
else
    rm -rf "${root_dir}/manifests"
fi
mkdir -p "${root_dir}/manifests"

for app in "${applications[@]}"
do
    #nix build --option substitute false "${root_dir}#${app}"
    nix build "${root_dir}#${app}" || error="true"
    cp ./result "${root_dir}/manifests/${app}.yaml" || error="true" # Copy file instead of using symlink
    chmod 644 "${root_dir}/manifests/${app}.yaml" || error="true"

    # Halt if failure encountered
    if [[ "${error}" == "true" ]]
    then
      printf "Error processing app \"%s\", halting execution\n" "${app}"
      rm -f "${root_dir}/manifests/${app}.yaml"
      exit 1
    fi
done
