#!/bin/sh
registry="${REGISTRY:-127.0.0.1:5000}"
images_file="${IMAGES_FILE:-/etc/nomad/images.txt}"
failed=0

while read -r source; do
  case "${source}" in
    "" | "#"*) continue ;;
  esac

  name="${source#docker.io/}"
  name="${name#library/}"
  echo "Syncing ${source} -> ${registry}/${name}"
  if ! skopeo copy --quiet --retry-times 3 --dest-tls-verify=false "docker://${source}" "docker://${registry}/${name}" < /dev/null; then
    echo "ERROR: failed to sync ${source}"
    failed=$((failed + 1))
  fi
done < "${images_file}"

if [ "${failed}" -gt 0 ]; then
  echo "${failed} image(s) failed to sync"
  exit 1
fi
echo "All images are synced"
