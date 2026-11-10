#!/bin/sh
set -u
umask 022

dest="${MIRROR_DEST:-/mirror}"
repo="${dest}/x86_64"
db=/tmp/pacman-db
packages="${PACMAN_PACKAGES:-firefox gnome-terminal ghostty meshtasticd kiwix-desktop python python-pip go gcc gdb make vim helix msedit}"
failed=0

mkdir -p "${repo}" "${db}/local"
pacman --dbpath "${db}" -Sy --noconfirm > /dev/null || exit 1

: > /tmp/status
available=""
for package in ${packages}; do
  if pacman --dbpath "${db}" -Si "${package}" > /dev/null 2>&1; then
    available="${available} ${package}"
    echo "included ${package}" >> /tmp/status
  else
    echo "ERROR: ${package} is not in the official Arch repositories"
    echo "missing ${package}" >> /tmp/status
    failed=$((failed + 1))
  fi
done

# shellcheck disable=SC2086
pacman --dbpath "${db}" -Sp --noconfirm ${available} 2> /dev/null | sed 's#.*/##' | sort -u > /tmp/wanted
if [ ! -s /tmp/wanted ]; then
  echo "ERROR: dependency resolution produced no packages"
  exit 1
fi

# shellcheck disable=SC2086
pacman --dbpath "${db}" --cachedir "${repo}" -Sw --noconfirm ${available} || failed=$((failed + 1))

for package_file in "${repo}"/*.pkg.tar.*; do
  [ -e "${package_file}" ] || continue
  name="${package_file##*/}"
  grep -qxF "${name%.sig}" /tmp/wanted || { echo "Removing superseded ${name}"; rm -f "${package_file}"; }
done

rm -f "${repo}"/nomad.db* "${repo}"/nomad.files*
repo-add --quiet "${repo}/nomad.db.tar.gz" "${repo}"/*.pkg.tar.zst || exit 1

{
  echo "Arch Linux package mirror, rebuilt $(date -u +%FT%TZ)"
  echo
  echo "Add to /etc/pacman.conf:"
  echo "  [nomad]"
  echo "  SigLevel = Optional TrustAll"
  echo "  Server = http://<nomad-host>/files/linux/pacman/\$arch"
  echo
  sort /tmp/status
} > "${dest}/README.txt"

echo "Mirror contains $(ls "${repo}"/*.pkg.tar.zst | wc -l) packages"
[ "${failed}" -eq 0 ]
