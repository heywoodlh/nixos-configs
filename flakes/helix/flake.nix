{
  description = "Helix editor flake";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    flake-utils.url = "github:numtide/flake-utils";
    helix-src = {
      url = "github:alevinval/helix/issue-2719";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = inputs @ {
    self,
    nixpkgs,
    flake-utils,
    helix-src,
  }:
    flake-utils.lib.eachDefaultSystem (system: let
      pkgs = import nixpkgs {
        inherit system;
      };

      myConfig = pkgs.writeText "config.toml" ''
        theme = "heywoodlh"

        [editor.cursor-shape]
        insert = "bar"
        normal = "block"

        [editor.whitespace.render]
        space = "trailing"
        tab = "trailing"
        nbsp = "trailing"
        nnbsp = "trailing"

        [editor.whitespace.characters]
        space = '·'
        tab = '┆'

        [editor.lsp]
        display-inlay-hints = true

        [editor.soft-wrap]
        enable = true

        [editor]
        auto-pairs = false
      '';

      helixConf = pkgs.stdenv.mkDerivation {
        name = "config.toml";
        builder = pkgs.bash;
        args = [ "-c" "${pkgs.coreutils}/bin/cp ${myConfig} $out" ];
      };
    in {
      packages = rec {
        helix-config = helixConf;
        helix-wrapper = pkgs.writeShellScriptBin "hx" ''
          PATH="${pkgs.nix}/bin:${pkgs.nil}/bin:$PATH"
          mkdir -p ~/.config/helix/themes
          cp -f ${self}/themes/heywoodlh.toml ~/.config/helix/themes
          ${helix-src.packages.${system}.helix}/bin/hx -c ${helixConf} $@
        '';
        helix = helix-src.packages.${system}.helix;
        default = helix-wrapper;
      };

      formatter = pkgs.alejandra;
    });
}
