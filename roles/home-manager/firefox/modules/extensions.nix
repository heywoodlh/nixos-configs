{ pkgs, ... }:

with pkgs.nur.repos.rycee.firefox-addons; [
  bitwarden
  darkreader
  gnome-shell-integration
  privacy-badger
  private-relay
  redirector
  ublock-origin
  vimium
]
