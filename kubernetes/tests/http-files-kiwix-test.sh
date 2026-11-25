#!/usr/bin/env bash
set -euo pipefail

repo_root=$(cd "$(dirname "${BASH_SOURCE[0]}")/../../.." && pwd)
manifest=$(<"${repo_root}/flakes/kube/manifests/http-files.yaml")
zims="${repo_root}/flakes/kube/kiwix/zims.txt"

[[ "${manifest}" == *"mountPath: /web/kiwix"* ]]
[[ "${manifest}" == *"path: /media/services_pool/kiwix"* ]]
[[ "${manifest}" == *"kind: CronJob"* ]]
[[ "${manifest}" == *"name: kiwix-zim-urls"* ]]
[[ "${manifest}" == *"name: kiwix-zim-downloader"* ]]
[[ "${manifest}" == *"name: kiwix-apk-downloader"* ]]
[[ "${manifest}" == *"name: kiwix-apk-sources"* ]]
[[ "${manifest}" == *"value: /kiwix/android"* ]]
[[ "${manifest}" != *"@"*"@"* ]]

while read -r category url rest; do
  [[ -n "${category}" ]]
  [[ "${url}" == https://lb.download.kiwix.org/zim/*.zim ]]
  [[ -z "${rest}" ]]
  [[ "${manifest}" == *"    ${category} ${url}"* ]]
done < "${zims}"

apks="${repo_root}/flakes/kube/kiwix/apks.txt"
while read -r name kind source pattern; do
  [[ "${name}" == *.apk ]]
  [[ "${kind}" == github || "${kind}" == url ]]
  [[ -n "${source}" ]]
  [[ "${manifest}" == *"    ${name} ${kind} ${source}"* ]]
done < "${apks}"

sh -n "${repo_root}/flakes/kube/kiwix/download.sh"
sh -n "${repo_root}/flakes/kube/kiwix/download-apks.sh"
