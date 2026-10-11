#!/usr/bin/env bash
set -euo pipefail

repo_root=$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)
host=$(<"${repo_root}/nixos/hosts/gaming-sarah.nix")
directmusic_check="winetricks list-installed | \${pkgs.gnugrep}/bin/grep -qx directmusic"

[[ "${host}" == *"${directmusic_check}"* ]]
[[ "${host}" == *'winetricks -q directmusic'* ]]
[[ "${host}" != *'winetricks -q directmusic gmdls'* ]]
