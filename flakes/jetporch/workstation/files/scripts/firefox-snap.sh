#!/usr/bin/env bash

snap remove --purge firefox
snap remove --purge snap-store
snap remove --purge snapd-desktop-integration
snap remove --purge gtk-common-themes
snap remove --purge gnome-3-38-2004
snap remove --purge core20
snap remove --purge bare
snap remove --purge snapd
apt remove -y --purge snapd
apt-mark hold snapd
apt-mark hold gnome-software-plugin-snap

add-apt-repository -y ppa:mozillateam/ppa
echo '
Package: *
Pin: release o=LP-PPA-mozillateam
Pin-Priority: 1001

Package: firefox
Pin: version 1:1snap1-0ubuntu2
Pin-Priority: -1
' | tee /etc/apt/preferences.d/mozilla-firefox

apt install firefox -y
