{ pkgs, ... }:

with pkgs.nur.repos.rycee.firefox-addons; [
  darkreader
  gnome-shell-integration
  kristofferhagen-nord-theme
  multi-account-containers
  noscript
  onepassword-password-manager
  persistentpin
  privacy-badger
  private-relay
  redirector
  ublock-origin
  vimium
]
