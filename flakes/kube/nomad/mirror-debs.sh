#!/bin/sh
set -u
umask 022
. /etc/nomad/lib.sh

dest="${MIRROR_DEST:-/mirror}"
pool="${dest}/pool"
extra="${dest}/extra"
work="${dest}/.work"
packages="${DEB_PACKAGES:-firefox gnome-terminal meshtasticd kiwix python3 python3-pip python3-venv python3-dev golang-go gcc g++ build-essential gdb make vim}"
failed=0

export DEBIAN_FRONTEND=noninteractive

apt-get update -qq || exit 1
apt-get install -y -qq --no-install-recommends ca-certificates curl gnupg apt-utils software-properties-common > /dev/null || exit 1

install -d -m 0755 /etc/apt/keyrings
curl -fsSL https://packages.mozilla.org/apt/repo-signing-key.gpg -o /etc/apt/keyrings/packages.mozilla.org.asc || exit 1
echo "deb [signed-by=/etc/apt/keyrings/packages.mozilla.org.asc] https://packages.mozilla.org/apt mozilla main" > /etc/apt/sources.list.d/mozilla.list
printf 'Package: *\nPin: origin packages.mozilla.org\nPin-Priority: 1000\n' > /etc/apt/preferences.d/mozilla
add-apt-repository -y ppa:meshtastic/beta > /dev/null || exit 1
apt-get update -qq || exit 1

rm -rf "${work}"
mkdir -p "${pool}" "${extra}" "${work}/dl"
: > "${work}/keep"
: > "${work}/need"
: > "${work}/status"

key_of() {
  base="${1##*/}"
  printf '%s\n' "${base%_*}"
}

local_debs=""
local_names=""
fetch_deb() {
  url="$(gh_asset_url "$1" "$2")"
  if [ -z "${url}" ]; then
    echo "ERROR: no release asset for $1"
    echo "missing $1" >> "${work}/status"
    failed=$((failed + 1))
    return
  fi
  file="${pool}/${url##*/}"
  if [ ! -s "${file}" ] && ! download "${url}" "${file}"; then
    echo "ERROR: failed to download ${url}"
    failed=$((failed + 1))
    return
  fi
  local_debs="${local_debs} ${file}"
  local_names="${local_names} $(dpkg-deb -f "${file}" Package)"
  key_of "${file}" >> "${work}/keep"
  echo "upstream ${url##*/}" >> "${work}/status"
}

fetch_deb mkasberg/ghostty-ubuntu 'ghostty_.*_amd64_24\.04\.deb$'
fetch_deb helix-editor/helix 'helix_.*_amd64\.deb$'

msedit_url="$(gh_asset_url microsoft/edit 'edit-.*-x86_64-linux-gnu\.tar\.gz$')"
if [ -n "${msedit_url}" ]; then
  msedit_file="${extra}/${msedit_url##*/}"
  if [ -s "${msedit_file}" ] || download "${msedit_url}" "${msedit_file}"; then
    for old in "${extra}"/edit-*-x86_64-linux-gnu.tar.gz; do
      [ "${old}" != "${msedit_file}" ] && rm -f "${old}"
    done
    echo "upstream extra/${msedit_file##*/}" >> "${work}/status"
  else
    failed=$((failed + 1))
  fi
else
  echo "ERROR: no release asset for microsoft/edit"
  failed=$((failed + 1))
fi

available=""
for package in ${packages}; do
  if apt-cache show "${package}" > /dev/null 2>&1; then
    available="${available} ${package}"
    echo "included ${package}" >> "${work}/status"
  else
    echo "ERROR: ${package} is not available for Ubuntu 24.04"
    echo "missing ${package}" >> "${work}/status"
    failed=$((failed + 1))
  fi
done

# shellcheck disable=SC2086
closure="$(apt-get install -s --no-install-recommends -o Dir::State::status=/dev/null ${available} ${local_debs} 2> /dev/null | sed -n 's/^Inst \([^ ]*\) (\([^ ]*\) .*/\1=\2/p')"
if [ -z "${closure}" ]; then
  echo "ERROR: dependency resolution produced no packages"
  exit 1
fi

for spec in ${closure}; do
  name="${spec%%=*}"
  version="${spec#*=}"
  case " ${local_names} " in
    *" ${name} "*) continue ;;
  esac
  encoded="$(printf '%s' "${version}" | sed 's/:/%3a/g')"
  echo "${name}_${encoded}" >> "${work}/keep"
  ls "${pool}/${name}_${encoded}_"*.deb > /dev/null 2>&1 || echo "${name}=${version}" >> "${work}/need"
done

echo "$(wc -l < "${work}/need") package(s) to download"
if [ -s "${work}/need" ]; then
  (cd "${work}/dl" && xargs -n 40 apt-get download -qq -o APT::Sandbox::User=root < "${work}/need") || failed=$((failed + 1))
  find "${work}/dl" -name '*.deb' -exec mv -f {} "${pool}/" \;
fi

for deb in "${pool}"/*.deb; do
  [ -e "${deb}" ] || continue
  grep -qxF "$(key_of "${deb}")" "${work}/keep" || { echo "Removing superseded ${deb##*/}"; rm -f "${deb}"; }
done

cd "${dest}" || exit 1
apt-ftparchive packages pool > Packages.new
mv -f Packages.new Packages
gzip -9kf Packages
apt-ftparchive release . > Release.new
mv -f Release.new Release

{
  echo "Ubuntu 24.04 package mirror, rebuilt $(date -u +%FT%TZ)"
  echo
  echo "Add to /etc/apt/sources.list.d/nomad.list:"
  echo "  deb [trusted=yes] http://<nomad-host>/files/linux/debs ./"
  echo
  sort "${work}/status"
} > README.txt

rm -rf "${work}"
echo "Mirror contains $(ls "${pool}" | wc -l) packages"
[ "${failed}" -eq 0 ]
