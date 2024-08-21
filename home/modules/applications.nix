{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.heywoodlh.home.applications;
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

  createApp = { name, command }: if pkgs.stdenv.isDarwin then {
    "Applications/${name}.app/Contents/MacOS/${name}" = {
      enable = true;
      source = pkgs.writeShellScript "${name}" ''
        ${command}
      '';
    };

    "Applications/${name}.app/Contents/Resources/${name}.icns" = {
      enable = true;
      source = (renameIcns "${name}");
    };

    "Applications/${name}.app/Contents/Info.plist" = {
      enable = true;
      text = ''
        <?xml version="1.0" encoding="UTF-8"?>
        <!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
        <plist version="1.0">
          <dict>
            <key>CFBundleExecutable</key>
            <string>${name}</string>
            <key>CFBundleIdentifier</key>
            <string>org.nixos.home-manager.${name}</string>
            <key>CFBundleName</key>
            <string>${name}</string>
            <key>CFBundlePackageType</key>
            <string>APPL</string>
            <key>CFBundleVersion</key>
            <string>1.0</string>
            <key>CFBundleIconFile</key>
            <string>${name}</string>
          </dict>
        </plist>
      '';
    };
  } else {
    ".local/share/applications/${name}.desktop" = {
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
    heywoodlh.home.applications = mkOption {
      default = [];
      description = ''
        List of custom applications to create.
      '';
      type = types.listOf (types.attrsOf types.str);
    };
  };

  config = {
    home.file = applicationsFiles;
  };
}
