{
  pkgs,
  asahi-widevine,
  lacros,
  ...
}: let
  widevine-installer = pkgs.stdenv.mkDerivation {
    name = "widevine-installer";
    src = asahi-widevine;
    buildInputs = with pkgs; [
      which
      python3
      squashfsTools
    ];
    installPhase = ''
      mkdir -p "$out/bin"
      cp widevine-installer "$out/bin/"
      cp widevine_fixup.py "$out/bin/"
      sed -e "s|unsquashfs|${pkgs.squashfsTools}/bin/unsquashfs|" -i "$out/bin/widevine-installer"
      sed -e "s|python3|${pkgs.python3}/bin/python3|" -i "$out/bin/widevine-installer"
      sed -e "s|read|#read|" -i "$out/bin/widevine-installer"
      sed -e 's|$(whoami)|root|' -i "$out/bin/widevine-installer"
      sed -e 's|URL=.*|URL="$DISTFILES_BASE"|' -i "$out/bin/widevine-installer"
    '';
  };
  widevine = pkgs.stdenv.mkDerivation {
    name = "widevine";
    buildInputs = with pkgs; [
      curl
      widevine-installer
    ];
    src = lacros;
    unpackPhase = "true";
    installPhase = ''
      mkdir -p "$out/"
      COPY_CONFIGS=0 INSTALL_BASE="$out" DISTFILES_BASE="file://$src" widevine-installer
    '';
  };
  chromiumWV = pkgs.runCommand "chromium-wv" {version = pkgs.chromium.version;} ''
    mkdir -p $out
    cp -a ${pkgs.chromium.browser}/* $out/
    chmod u+w $out/libexec/chromium
    cp -Lr ${widevine}/WidevineCdm $out/libexec/chromium/
  '';
  chromiumWidevineWrapper = pkgs.chromium.overrideAttrs (prev: {
    buildCommand = builtins.replaceStrings ["${pkgs.chromium.browser}"] ["${chromiumWV}"] prev.buildCommand;
  });
in
  pkgs.writeShellScriptBin "chromium" ''
    ${chromiumWidevineWrapper}/bin/chromium $@
  ''
