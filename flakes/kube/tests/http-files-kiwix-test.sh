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
[[ "${manifest}" != *"@"*"@"* ]]

while read -r category url rest; do
  [[ -n "${category}" ]]
  [[ "${url}" == https://lb.download.kiwix.org/zim/*.zim ]]
  [[ -z "${rest}" ]]
  [[ "${manifest}" == *"    ${category} ${url}"* ]]
done < "${zims}"

sh -n "${repo_root}/flakes/kube/kiwix/download.sh"
