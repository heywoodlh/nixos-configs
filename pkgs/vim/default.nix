{
  lib,
  pkgs,
  neovim,
  mods,
  ...
}: let
  lstToString = lib.lists.foldr (a: b: a + "\n" + b) "";
  modDefaults = {
    plugins = [];
    rc = "";
  };
  getModRC = mod: (modDefaults // mod).rc;
  getModPlugins = mod: (modDefaults // mod).plugins;
  modsRC = lstToString (map getModRC mods);
  modsPlugins = lib.lists.concatMap getModPlugins mods;
in
  pkgs.wrapNeovim neovim {
    vimAlias = true;
    viAlias = true;
    neovimRcContent = modsRC;
    plugins = modsPlugins;
  }
