{ pkgs, ... }:

with pkgs.nur.repos.rycee.firefox-addons; [
  darkreader
  gnome-shell-integration
  noscript
  onepassword-password-manager
  privacy-badger
  private-relay
  redirector
  ublock-origin
  vimium
]
