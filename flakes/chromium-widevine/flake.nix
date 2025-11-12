{
  description = "Chromium bundled with Widevine for ARM64";
  inputs = {
    asahi-widevine = {
      url = "github:AsahiLinux/widevine-installer";
      flake = false;
    };
    lacros = {
      url = "https://commondatastorage.googleapis.com/chromeos-localmirror/distfiles/chromeos-lacros-arm64-squash-zstd-120.0.6098.0";
      flake = false;
    };
  };

  outputs = { self, nixpkgs, asahi-widevine, lacros, }:
  let
    pkgs = nixpkgs.legacyPackages.aarch64-linux;
    # Widevine
    widevine-installer = pkgs.stdenv.mkDerivation rec {
      name = "widevine-installer";
      src = asahi-widevine;
      buildInputs = with pkgs; [ which python3 squashfsTools ];

      installPhase = ''
        mkdir -p "$out/bin"
        cp widevine-installer "$out/bin/"
        cp widevine_fixup.py "$out/bin/"
        echo "$(which unsquashfs)"
        sed -e "s|unsquashfs|$(which unsquashfs)|" -i "$out/bin/widevine-installer"
        sed -e "s|python3|$(which python3)|" -i "$out/bin/widevine-installer"
        sed -e "s|read|#read|" -i "$out/bin/widevine-installer"
        sed -e 's|$(whoami)|root|' -i "$out/bin/widevine-installer"
        sed -e 's|URL=.*|URL="$DISTFILES_BASE"|' -i "$out/bin/widevine-installer"
      '';
    };
    widevine = pkgs.stdenv.mkDerivation {
      name = "widevine";
      buildInputs = with pkgs; [ curl widevine-installer ];

      src = lacros;

      unpackPhase = "true";
      installPhase = ''
        mkdir -p "$out/"
        COPY_CONFIGS=0 INSTALL_BASE="$out" DISTFILES_BASE="file://$src" widevine-installer
      '';
    };
    chromiumWV = pkgs.runCommand "chromium-wv" { version = pkgs.chromium.version; } ''
      mkdir -p $out
      cp -a ${pkgs.chromium.browser}/* $out/
      chmod u+w $out/libexec/chromium
      cp -Lr ${widevine}/WidevineCdm $out/libexec/chromium/
    '';
    chromiumWidevineWrapper = pkgs.chromium.overrideAttrs (prev: {
      buildCommand = builtins.replaceStrings [ "${pkgs.chromium.browser}" ] [ "${chromiumWV}" ] prev.buildCommand;
    });
  in {
    packages.aarch64-linux.chromium-widevine = pkgs.writeShellScriptBin "chromium" ''
      ${chromiumWidevineWrapper}/bin/chromium $@
    '';
  };
}
