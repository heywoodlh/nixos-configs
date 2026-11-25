#!/bin/sh
umask 022
. /etc/nomad/lib.sh

root="${FILES_ROOT:-/srv}"
linux="${root}/linux"
appimages_file="${APPIMAGES_FILE:-/etc/nomad/appimages.txt}"
nixos_channel="${NIXOS_CHANNEL:-nixos-26.05}"
failed=0

mkdir -p "${root}/android" "${root}/maps" "${linux}/appimages" "${linux}/debs" "${linux}/apk" "${linux}/pacman"

fetch_iso() {
  name="$1"
  url="$2"
  sha="$3"
  pattern="$4"
  dest="${linux}/${name}"

  if [ -s "${dest}" ]; then
    echo "Up to date: ${name}"
    return 0
  fi

  echo "Downloading ${name}"
  if ! download "${url}" "${dest}"; then
    echo "ERROR: failed to download ${url}"
    failed=$((failed + 1))
    return 1
  fi

  actual="$(sha256sum "${dest}" | cut -d' ' -f1)"
  if [ -n "${sha}" ] && [ "${actual}" != "${sha}" ]; then
    echo "ERROR: checksum mismatch for ${name}"
    rm -f "${dest}"
    failed=$((failed + 1))
    return 1
  fi

  for old in "${linux}"/${pattern}; do
    [ -e "${old}" ] && [ "${old}" != "${dest}" ] && rm -f "${old}"
  done
  return 0
}

ubuntu() {
  base="https://releases.ubuntu.com/24.04"
  entry="$(curl -fsSL --retry 3 "${base}/SHA256SUMS" | awk '$2 ~ /desktop-amd64\.iso$/ { sub(/^\*/, "", $2); print $2, $1 }' | sort -V | tail -1)"
  [ -n "${entry}" ] || { echo "ERROR: could not resolve Ubuntu 24.04 ISO"; failed=$((failed + 1)); return; }
  fetch_iso "${entry% *}" "${base}/${entry% *}" "${entry#* }" "ubuntu-24.04*-desktop-amd64.iso"
}

nixos() {
  url="$(curl -fsSIL --retry 3 -o /dev/null -w '%{url_effective}' "https://channels.nixos.org/${nixos_channel}/latest-nixos-graphical-x86_64-linux.iso")"
  name="${url##*/}"
  case "${name}" in
    nixos-graphical-*-x86_64-linux.iso) ;;
    *) echo "ERROR: could not resolve NixOS ISO (${url})"; failed=$((failed + 1)); return ;;
  esac
  sha="$(curl -fsSL --retry 3 "${url}.sha256" | cut -d' ' -f1)"
  fetch_iso "${name}" "${url}" "${sha}" "nixos-graphical-*-x86_64-linux.iso"
}

arch() {
  base="https://geo.mirror.pkgbuild.com/iso/latest"
  entry="$(curl -fsSL --retry 3 "${base}/sha256sums.txt" | awk '$2 ~ /^archlinux-[0-9.]+-x86_64\.iso$/ { print $2, $1 }' | sort -V | tail -1)"
  [ -n "${entry}" ] || { echo "ERROR: could not resolve Arch Linux ISO"; failed=$((failed + 1)); return; }
  fetch_iso "${entry% *}" "${base}/${entry% *}" "${entry#* }" "archlinux-*-x86_64.iso"
}

alpine() {
  base="https://dl-cdn.alpinelinux.org/alpine/latest-stable/releases/x86_64"
  name="$(curl -fsSL --retry 3 "${base}/" | grep -o 'alpine-standard-[0-9.]*-x86_64\.iso' | sort -uV | tail -1)"
  [ -n "${name}" ] || { echo "ERROR: could not resolve Alpine Linux ISO"; failed=$((failed + 1)); return; }
  sha="$(curl -fsSL --retry 3 "${base}/${name}.sha256" | cut -d' ' -f1)"
  fetch_iso "${name}" "${base}/${name}" "${sha}" "alpine-standard-*-x86_64.iso"
}

appimages() {
  dest_dir="${linux}/appimages"
  while read -r kind source pattern; do
    case "${kind}" in
      "" | "#"*) continue ;;
    esac

    case "${kind}" in
      github)
        url="$(gh_asset_url "${source}" "${pattern}")"
        file="${url##*/}"
        ;;
      url)
        url="${source}"
        file="${pattern}"
        ;;
      *)
        echo "ERROR: unknown source kind ${kind}"
        failed=$((failed + 1))
        continue
        ;;
    esac

    if [ -z "${url}" ]; then
      echo "ERROR: no release asset for ${source} ${pattern}"
      failed=$((failed + 1))
      continue
    fi

    size="$(remote_size "${url}" | tr -d ' ')"
    dest="${dest_dir}/${file}"
    if [ -n "${size}" ] && [ -f "${dest}" ] && [ "$(wc -c < "${dest}")" = "${size}" ]; then
      echo "Up to date: ${file}"
      continue
    fi

    echo "Downloading ${file}"
    if download "${url}" "${dest}"; then
      chmod 755 "${dest}"
      if [ "${kind}" = github ]; then
        for old in "${dest_dir}"/*; do
          [ "${old}" != "${dest}" ] && printf '%s\n' "${old##*/}" | grep -Eq "${pattern}" && rm -f "${old}"
        done
      fi
    else
      echo "ERROR: failed to download ${url}"
      failed=$((failed + 1))
    fi
  done < "${appimages_file}"
}

ubuntu
nixos
arch
alpine
appimages

if [ "${failed}" -gt 0 ]; then
  echo "${failed} download(s) failed; restart the pod to retry"
fi
exit 0
