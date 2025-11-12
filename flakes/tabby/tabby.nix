{
  pkgs,
  lib,
  stdenv,
  fetchurl,
  makeWrapper,
  autoPatchelfHook,
  unzip,
  glibc,
  musl,
  fontconfig,
  expat,
  libxkbcommon,
  alsa-lib,
  xorg,
  gtk3,
  nss,
  libdrm,
  mesa,
  dpkg,
  libGL,
}:

let
  myTabbyVersion = "1.0.214";
  x86_64-darwin-hash = "0gp50qgccgyis52kkh8p3ckicgz97363x1sbglp43bz7jbj05dm5";
  aarch64-darwin-hash = "104n14lyarw0wi3h458mq5xh905c3drk1zdcs499gf8hbyri1bpi";
  x86_64-linux-hash = "16sk7f7752pnfjs90xlpbdcjp88ll244fjsz0x6ay94k85lj6qhr";
  aarch64-linux-hash = "0j61dxlf9mnbbqgrg0ry995xn0cl2ardfim9czbk0kmybsjjibvn";
  sources = {
    x86_64-darwin = fetchurl {
      url = "https://github.com/Eugeny/tabby/releases/download/v${myTabbyVersion}/tabby-${myTabbyVersion}-macos-x86_64.zip";
      sha256 = x86_64-darwin-hash;
    };
    aarch64-darwin = fetchurl {
      url = "https://github.com/Eugeny/tabby/releases/download/v${myTabbyVersion}/tabby-${myTabbyVersion}-macos-arm64.zip";
      sha256 = aarch64-darwin-hash;
    };
    x86_64-linux = fetchurl {
      url = "https://github.com/Eugeny/tabby/releases/download/v${myTabbyVersion}/tabby-${myTabbyVersion}-linux-x64.deb";
      sha256 = x86_64-linux-hash;
    };
    aarch64-linux = fetchurl {
      url = "https://github.com/Eugeny/tabby/releases/download/v${myTabbyVersion}/tabby-${myTabbyVersion}-linux-arm64.deb";
      sha256 = aarch64-linux-hash;
    };
  };
in stdenv.mkDerivation (finalAttrs: {
  pname = "tabby";
  version = "${myTabbyVersion}";

  src = sources.${stdenv.hostPlatform.system} or (throw "unsupported system: ${stdenv.hostPlatform.system}");

  nativeBuildInputs = lib.optionals stdenv.isLinux [ autoPatchelfHook stdenv.cc.cc.lib glibc fontconfig musl expat libxkbcommon alsa-lib xorg.libXrandr gtk3 nss libdrm mesa dpkg ];
  buildInputs = [ makeWrapper unzip ];

  unpackPhase = lib.optionalString stdenv.isLinux ''
    dpkg-deb --fsys-tarfile $src | \
      tar -x --no-same-owner
    mv usr $out
  '';

  appendRunpaths = [ ( lib.makeLibraryPath [ libGL ] ) ];

  buildPhase = if stdenv.isDarwin then ''
    mkdir -p $out/bin $out/Tabby.app
    cp -r * $out/Tabby.app
    makeWrapper "$out/Tabby.app/Contents/MacOS/Tabby" "$out/bin/tabby"
  '' else ''
    mkdir -p $out/bin $out/tabby.app
    cp -r * $out
    makeWrapper "$out/opt/Tabby/tabby" "$out/bin/tabby"
  '';
})
