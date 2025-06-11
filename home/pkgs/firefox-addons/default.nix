{ fetchurl, lib, stdenv, ... }@args:

let
  buildFirefoxXpiAddon = lib.makeOverridable ({ stdenv ? args.stdenv
    , fetchurl ? args.fetchurl, pname, version, addonId, url, sha256, meta, ...
    }:
    stdenv.mkDerivation {
      name = "${pname}-${version}";

      inherit meta;

      src = fetchurl { inherit url sha256; };

      preferLocalBuild = true;
      allowSubstitutes = true;

      passthru = { inherit addonId; };

      buildCommand = ''
        dst="$out/share/mozilla/extensions/{ec8030f7-c20a-464f-9b0e-13a3a9e97384}"
        mkdir -p "$dst"
        install -v -m644 "$src" "$dst/${addonId}.xpi"
      '';
    });

  packages = {
    inherit buildFirefoxXpiAddon;

    heywoodlh-container = let version = "1.6.0";
    in buildFirefoxXpiAddon {
      pname = "heywoodlh-container";
      inherit version;
      addonId = "@heywoodlh-container";
      url =
        "https://github.com/heywoodlh/firefox-container/releases/download/${version}/heywoodlh_container-${version}.zip";
      sha256 = "sha256-r1MO5stiIl6nd/1wKxu97LjE5gzajH+mYPTsLUPZBhE=";
      meta = with lib; {
        homepage = "https://github.com/heywoodlh/firefox-container";
        description =
          "Isolate multiple services in one extension with Firefox Containers.";
        license = licenses.mpl20;
        platforms = platforms.all;
      };
    };
  };

in packages
