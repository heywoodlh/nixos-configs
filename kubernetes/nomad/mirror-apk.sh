#!/bin/sh
set -u
umask 022

dest="${MIRROR_DEST:-/mirror}"
arch="$(apk --print-arch)"
repo="${dest}/${arch}"
keys="${dest}/keys"
packages="${APK_PACKAGES:-firefox gnome-terminal ghostty meshtasticd kiwix-desktop python3 py3-pip python3-dev go gcc g++ build-base musl-dev gdb make vim helix msedit socat}"
failed=0

apk add --no-cache abuild openssl > /dev/null || exit 1
mkdir -p "${repo}" "${keys}"
ln -sfn "${arch}" "${dest}/noarch"

if [ ! -f "${keys}/nomad.rsa" ]; then
  openssl genrsa -out "${keys}/nomad.rsa" 4096 2> /dev/null || exit 1
  openssl rsa -in "${keys}/nomad.rsa" -pubout -out "${keys}/nomad.rsa.pub" 2> /dev/null || exit 1
fi
cp "${keys}/nomad.rsa.pub" "${dest}/nomad.rsa.pub"

: > /tmp/status
available=""
for package in ${packages}; do
  if apk search -x "${package}" | grep -q .; then
    available="${available} ${package}"
    echo "included ${package}" >> /tmp/status
  else
    echo "ERROR: ${package} is not packaged in Alpine $(cat /etc/alpine-release)"
    echo "missing ${package}" >> /tmp/status
    failed=$((failed + 1))
  fi
done

# shellcheck disable=SC2086
apk fetch --recursive --simulate ${available} 2>&1 | sed -n 's/^Downloading //p' > /tmp/wanted
if [ ! -s /tmp/wanted ]; then
  echo "ERROR: dependency resolution produced no packages"
  exit 1
fi
sed 's/$/.apk/' /tmp/wanted | sort -u > /tmp/wanted.apk

# shellcheck disable=SC2086
apk fetch --recursive --output "${repo}" ${available} || failed=$((failed + 1))

for apk_file in "${repo}"/*.apk; do
  [ -e "${apk_file}" ] || continue
  grep -qxF "${apk_file##*/}" /tmp/wanted.apk || { echo "Removing superseded ${apk_file##*/}"; rm -f "${apk_file}"; }
done

rm -f "${repo}/APKINDEX.tar.gz"
apk index --output "${repo}/APKINDEX.tar.gz" "${repo}"/*.apk || exit 1
abuild-sign -k "${keys}/nomad.rsa" "${repo}/APKINDEX.tar.gz" || exit 1

{
  echo "Alpine $(cat /etc/alpine-release) package mirror, rebuilt $(date -u +%FT%TZ)"
  echo
  echo "Trust the signing key and add the repository:"
  echo "  wget -O /etc/apk/keys/nomad.rsa.pub http://<nomad-host>/files/linux/apk/nomad.rsa.pub"
  echo "  echo http://<nomad-host>/files/linux/apk >> /etc/apk/repositories"
  echo
  sort /tmp/status
} > "${dest}/README.txt"

echo "Mirror contains $(ls "${repo}"/*.apk | wc -l) packages"
[ "${failed}" -eq 0 ]
