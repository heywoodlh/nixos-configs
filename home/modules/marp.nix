{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.heywoodlh.home.marp;
  marpNord = pkgs.fetchFromGitHub {
    owner = "heywoodlh";
    repo = "marp-nord";
    rev = "16431c6742e381722c72107e00b35866c42e4a24";
    hash = "sha256-JlUrFIy56MwKGkgvT/Dl5iJKd3gbgGyI8f8pSO3SgHU=";
  };
  marpTemplate = pkgs.writeText "presentation.md" ''
    ---
    Title: My Presentation
    theme: nord
    ---

    # Title

    ---

    # Slide 1

    ```
    #!/usr/bin/env bash
    echo "Stuff!"
    ```
  '';
  marpGenerator = pkgs.writeShellScriptBin "marp-gen.sh" ''
    if [[ -z $1 ]]
    then
      printf "Usage: $0 filename.md\nNo file name provided. Exiting.\n"
      exit 0
    else
      cp -v ${marpTemplate} "$1"
      chmod +w "$1"
    fi
  '';
  marpWrapper = pkgs.writeShellScriptBin "marp" ''
    ${pkgs.marp-cli}/bin/marp --theme="${marpNord}/build/nord-theme.css" $@
  '';
in {
  options = {
    heywoodlh.home.marp = {
      enable = mkOption {
        default = false;
        description = ''
          Enable heywoodlh marp configuration.
        '';
        type = types.bool;
      };
    };
  };

  config = mkIf cfg.enable {
    home.packages = [
      marpGenerator
      marpWrapper
    ];
  };
}
