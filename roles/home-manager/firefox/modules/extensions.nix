{ pkgs, ... }:

with pkgs.nur.repos.rycee.firefox-addons; [
  bitwarden
  darkreader
  gnome-shell-integration
  noscript
  privacy-badger
  private-relay
  redirector
  ublock-origin
  vimium
]
