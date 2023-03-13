{ config, pkgs, ... }:

let
  version = "0.11.0";
  cerebro = pkgs.appimageTools.wrapType2 {
    name = "Cerebro";
    src = pkgs.fetchurl {
      url = "https://github.com/cerebroapp/cerebro/releases/download/v${version}/Cerebro-${version}.AppImage";
      sha256 = "sha256-+rjAMoQI3KTmHGFnyFoe20qIrAEi0DL3ksInFy677P8=";
    };
  };
in {
  environment.systemPackages = [ cerebro ];
}
