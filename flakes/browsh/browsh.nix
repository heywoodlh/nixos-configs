{ lib, buildGoModule, fetchurl, fetchFromGitHub, buildNpmPackage, nodePackages, zip, stdenv, firefox, }:

let
  src = fetchFromGitHub {
    owner = "browsh-org";
    repo = "browsh";
    rev = "vim-mode-2022";
    hash = "sha256-77fHkhhLdftVvj7OMveVHLB4n6PjPX2eggRvXwVYpGs=";
  };

  webext = buildNpmPackage rec {
    name = "browsh-xpi";
    inherit src;

    nativeBuildInputs = [nodePackages.webpack-cli zip];
    buildInputs = [ firefox ];
    dontNpmBuild = true;

    installPhase = ''
      $preInstall
      pushd webext
      npm ci
      webpack-cli -o .
      cd dist
      mkdir -p $out
      zip $out/browsh.xpi -r .
      popd
      $postInstall
    '';

    postPatch = ''
      cp ${src}/webext/package-lock.json package-lock.json
    '';

    npmDepsHash = "sha256-ovyi/k/P6gYyAPQt2co3AgELYbDvCZ16P/LktsP+uHk=";
  };
in buildGoModule rec {
  name = "browsh";
  inherit src;

  sourceRoot = "${src.name}/interfacer";

  vendorHash = "sha256-ANmVv0+dU2qUeUCJL7os0O/aUNmNeGCUhCrZOWkrpgk=";

  preBuild = ''
    cp "${webext}/browsh.xpi" src/browsh/browsh.xpi
  '';

  # Tests require network access
  doCheck = false;

  meta = with lib; {
    description = "A fully-modern text-based browser, rendering to TTY and browsers";
    mainProgram = "browsh";
    homepage = "https://www.brow.sh/";
    license = lib.licenses.lgpl21;
    platforms = lib.platforms.linux ++ lib.platforms.darwin;
  };
}
