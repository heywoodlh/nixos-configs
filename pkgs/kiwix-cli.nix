{ lib, rustPlatform, fetchFromGitHub }:

rustPlatform.buildRustPackage rec {
  pname = "kiwix-cli";
  version = "0.2.0";

  src = fetchFromGitHub {
    owner = "joey5403";
    repo = "kiwix-cli";
    tag = "v${version}";
    hash = "sha256-Txem1M5pcee0Kkw2Ku6TyWbi6cGpPUZVWsh9C4zhnPM=";
  };

  cargoHash = "sha256-ToFbemelHn4xiboKor+w3Xf2VCkkWtOuXHnchGCaNvA=";
  doCheck = false;

  postInstall = ''
    install -Dm644 man/kiwix-cli.1 $out/share/man/man1/kiwix-cli.1
  '';

  meta = {
    description = "Keyboard-first Ratatui reader for Kiwix servers";
    homepage = "https://github.com/joey5403/kiwix-cli";
    license = lib.licenses.mit;
    mainProgram = "kiwix-cli";
  };
}
