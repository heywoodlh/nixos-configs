{
  pkgs,
  helix-src,
  nixpkgs-stable,
  asahi-widevine,
  lacros,
  ...
}: let
  call = file:
    pkgs.callPackage file {
      inherit helix-src nixpkgs-stable asahi-widevine lacros;
    };
  fish = call ./fish;
  helix = call ./helix;
  vimMods = pkgs.callPackage ./vim/settings {};
in {
  inherit (fish) fish tmux ghostty zellij op-wrapper;
  "ghostty-config" = fish.ghostty-config;
  inherit (helix) helix helix-wrapper helix-config;
  vim = pkgs.callPackage ./vim {
    mods = vimMods;
    neovim = pkgs.neovim-unwrapped;
    inherit (pkgs) vimPlugins;
  };
  gnome-install-extensions = call ./gnome-extensions.nix;
  chromium-widevine = call ./chromium-widevine.nix;
}
