#!/usr/bin/env bash

# Packages to install from the AUR
pkgs="trizen"

# Exit on errors
set -e

# Output format
info() { echo -e "\e[34m:: $@\e[0m"; }
warning() { echo -e "\e[33m:: $@\e[0m"; }
error() { echo -e "\e[31m:: $@\e[0m"; }

# Make directory and enter it
mkcd() { mkdir -p "$1" && cd "$1"; }

# Cannot run as root user
test "$UID" -gt 0 || { error "This script cannot be run as root."; exit;}

# Update Cached sudo credentials
info "Updating cached sudo credentials"
sudo -v

# Install base-devel and cURL if not already installed
info "Installing system requirements"
sudo pacman -S --needed --noconfirm base-devel curl

# Create temporary directory for build
buildroot=$(mktemp -d /tmp/install-trizen-XXXXXXXX)
mkdir -p ${buildroot}
info "Created temp directory: $buildroot"

# Set PKGBUILD base URI
pkgbuild="https://aur.archlinux.org/cgit/aur.git/plain/PKGBUILD?h"
info "Set PKGBUILD base URI: $pkgbuild"

# Install each package set in $pkgs
info "Installing packages: $pkgs"
for pkg in $pkgs; do
    info "Create subdirectory for $pkg"
    mkcd "$buildroot/$pkg"

    info "Retrieving PKGBUILD: $pkgbuild=$pkg"
    curl -o PKGBUILD "$pkgbuild=$pkg"

    valid_pgp_keys=$(sed -n "s:^validpgpkeys=('\([0-9A-Fa-fx]\+\)').*$:\1:p" PKGBUILD)
    info "Receiving PGP keys from PKGBUILD for $pkg: $valid_pgp_keys"
    gpg --recv-keys $valid_pgp_keys

    info "Making and installing package for $pkg"
    makepkg --syncdeps --install --needed --noconfirm
done

info "Cleaning up temporary buildroot: $buildroot"
rm -rf ${buildroot}
info "Finished!"

