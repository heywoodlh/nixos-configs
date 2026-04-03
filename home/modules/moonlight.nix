{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.heywoodlh.home.moonlight;
  moonlight-heywoodlh = pkgs.moonlight-qt.overrideAttrs (oldAttrs: {
    version = "unstable-2026-04-03";
    src = pkgs.fetchFromGitHub {
      owner = "moonlight-stream";
      repo = "moonlight-qt";
      rev = "78bc2141f69c512fda23197456f4869e4961c081";
      hash = "sha256-360bl9hsqpUs/tmTo3HA89GNJz6Tf8MJUcfYQAqigmY=";
      fetchSubmodules = true;
    };
    # Remove patches that may not apply to the current rev
    patches = [];
  });
in {
  options = {
    heywoodlh.home.moonlight = mkOption {
      default = false;
      description = ''
        Use more recent build of Moonlight.
      '';
      type = types.bool;
    };
  };

  config = mkIf cfg {
    home.packages = [
      moonlight-heywoodlh
    ];
  };
}
