{
  pkgs,
  nixpkgs-stable,
  ...
}: let
  stable = import nixpkgs-stable {
    inherit (pkgs.stdenv.hostPlatform) system;
    config.allowUnfree = true;
  };
in
  pkgs.writeShellScriptBin "gnome-ext-install" ''
    declare -a extensions=("caffeine@patapon.info"
                           "gnomebedtime@ionutbortis.gmail.com"
                           "gsconnect@andyholmes.github.io"
                           "just-perfection-desktop@just-perfection"
                           "native-window-placement@gnome-shell-extensions.gcampax.github.com"
                           "hide-cursor@elcste.com"
                           "user-theme@gnome-shell-extensions.gcampax.github.com"
                           "space-bar@luchrioh"
                           "pip-on-top@rafostar.github.com")

    for extension in "''${extensions[@]}"
    do
      ${stable.gnome-extensions-cli}/bin/gext install "$extension"
      ${stable.gnome-extensions-cli}/bin/gext enable "$extension"
    done
  ''
