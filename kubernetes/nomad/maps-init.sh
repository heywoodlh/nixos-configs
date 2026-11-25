#!/bin/sh
umask 022
data=/data
failed=0

mkdir -p "${data}/bin" "${data}/regions" "${data}/assets/sprites/v4" "${data}/assets/fonts"

fetch() {
  [ -s "$2" ] && return 0
  mkdir -p "$(dirname "$2")"
  if curl -fsSL --retry 5 --retry-delay 5 --connect-timeout 30 -o "$2.part" "$1"; then
    mv -f "$2.part" "$2"
  else
    rm -f "$2.part"
    echo "ERROR: failed to download $1"
    failed=$((failed + 1))
  fi
}

if [ "$(cat "${data}/bin/pmtiles.version" 2> /dev/null)" != "${PMTILES_VERSION}" ]; then
  echo "Installing pmtiles ${PMTILES_VERSION}"
  if curl -fsSL --retry 5 --retry-delay 5 --connect-timeout 30 \
    "https://github.com/protomaps/go-pmtiles/releases/download/v${PMTILES_VERSION}/go-pmtiles_${PMTILES_VERSION}_Linux_x86_64.tar.gz" \
    | tar xz -C "${data}/bin" pmtiles; then
    printf '%s\n' "${PMTILES_VERSION}" > "${data}/bin/pmtiles.version"
  else
    echo "ERROR: failed to install pmtiles"
    failed=$((failed + 1))
  fi
fi

cdn="https://cdn.jsdelivr.net/npm"
fetch "${cdn}/maplibre-gl@${MAPLIBRE_VERSION}/dist/maplibre-gl.js" "${data}/assets/maplibre-gl.js"
fetch "${cdn}/maplibre-gl@${MAPLIBRE_VERSION}/dist/maplibre-gl.css" "${data}/assets/maplibre-gl.css"
fetch "${cdn}/pmtiles@${PMTILES_JS_VERSION}/dist/pmtiles.js" "${data}/assets/pmtiles.js"
fetch "${cdn}/@protomaps/basemaps@${BASEMAPS_VERSION}/dist/basemaps.js" "${data}/assets/basemaps.js"

assets="https://protomaps.github.io/basemaps-assets"
for sprite in light.json light.png light@2x.json light@2x.png; do
  fetch "${assets}/sprites/v4/${sprite}" "${data}/assets/sprites/v4/${sprite}"
done

for font in "Noto Sans Regular" "Noto Sans Medium" "Noto Sans Italic"; do
  encoded="$(printf '%s' "${font}" | sed 's/ /%20/g')"
  for range in 0-255 256-511 512-767 768-1023 1024-1279 8192-8447; do
    fetch "${assets}/fonts/${encoded}/${range}.pbf" "${data}/assets/fonts/${font}/${range}.pbf"
  done
done

if [ "${failed}" -gt 0 ]; then
  echo "${failed} asset download(s) failed; restart the pod to retry"
fi
exit 0
