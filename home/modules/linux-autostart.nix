{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.heywoodlh.home.autostart;
  system = pkgs.system;
  snowflake = pkgs.fetchurl {
    url = "https://raw.githubusercontent.com/NixOS/nixos-artwork/e3a74d1c40086393f2b1b9f218497da2db0ff3ae/logo/white.png";
    hash = "sha256-0Ni0KWk8QlhfXIPXyRUo8566a4VYHbMcAD90g5QvpF0=";
  };
  icnsDir = ./icns;
  renameIcns = name: pkgs.stdenv.mkDerivation {
    name = "icns-renamed-${name}";
    src = icnsDir;
    phases = [ "unpackPhase" "installPhase" ];

    unpackPhase = ''
      mkdir -p $out
      cp -r $src/* $out/
    '';

    installPhase = ''
      for file in $out/*.icns; do
        new_name=$(basename "$file" | sed "s/^white/${name}/")
        mv "$file" "$out/$new_name"
      done
    '';
  };

  createApp = { name, command }: {
    ".config/autostart/${name}.desktop" = {
      enable = true;
      text = ''
        [Desktop Entry]
        Name=${name}
        GenericName=${name}
        Comment=${name}
        Exec=${command}
        Terminal=false
        Type=Application
        Keywords=command;
        Icon=${snowflake}
        Categories=Utility;
      '';
    };
  };

  applicationsFiles = foldl' (acc: app: acc // (createApp app)) {} cfg;

in {
  options = {
    heywoodlh.home.autostart = mkOption {
      default = [];
      description = ''
        List of custom applications to autostart.
      '';
      type = types.listOf (types.attrsOf types.str);
    };
  };

  config = {
    home.file = applicationsFiles;
  };
}
