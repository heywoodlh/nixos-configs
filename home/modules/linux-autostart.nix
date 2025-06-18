{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.heywoodlh.home.autostart;
  system = pkgs.system;
  snowflake = ../../assets/nixos-snowflake.png;
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
