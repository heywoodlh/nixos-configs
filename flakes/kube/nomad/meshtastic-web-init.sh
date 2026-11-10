#!/bin/sh
set -eu

src=/usr/share/nginx/html
out=/data/html
prefix=/meshtastic

rm -rf "${out}.new"
mkdir -p "${out}.new"
cp -a "${src}/." "${out}.new/"
cd "${out}.new"

sed -i -E "s#(src|href)=\"/#\\1=\"${prefix}/#g" index.html

find . -type f \( -name '*.js' -o -name '*.html' -o -name '*.webmanifest' -o -name '*.json' \) -exec sed -i -E \
  -e "s#([\`'\"])/(index-|dist-|worker-|sqlite3-|maplibre-gl-|manifest\\.webmanifest|site\\.webmanifest|logo\\.svg|chirpy\\.svg|icon\\.svg|favicon\\.ico|apple-touch-icon|i18n/|devices/|sw\\.js)#\\1${prefix}/\\2#g" \
  -e "s#scope: '/'#scope: '${prefix}/'#g" \
  -e "s#([A-Za-z_\$][A-Za-z0-9_\$]*)\\(\\{routeTree:#\\1({basepath:\"${prefix}\",routeTree:#g" \
  {} +

grep -q "basepath:\"${prefix}\"" index-*.js || { echo "router basepath patch did not apply" >&2; exit 1; }

rm -rf "${out}"
mv "${out}.new" "${out}"
