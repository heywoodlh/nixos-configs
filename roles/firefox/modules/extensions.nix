{ pkgs, ... }:

with pkgs.nur.repos.rycee.firefox-addons; [
  bitwarden
  darkreader
  firenvim
  gnome-shell-integration
  privacy-badger
  private-relay
  redirector
  ublock-origin
  vimium
]
