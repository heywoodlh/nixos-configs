{
  description = "Helix editor flake";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.05";
    flake-utils.url = "github:numtide/flake-utils";
    helix-src = {
      url = "github:alevinval/helix/issue-2719";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.flake-utils.follows = "flake-utils";
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
        theme = "base16_transparent"

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

        [editor]
        auto-pairs = false
      '';

      helixPkg = helix-src.packages.${system}.helix.override {
        grammarOverlays = [
          (final: prev: {
            perl = prev.perl.overrideAttrs (old: {
              FLAGS = old.FLAGS ++ ["-std=gnu17"];
            });
            # Upstream elliotfontaine/tree-sitter-cylc was deleted; this mirror is byte-identical.
            cylc = prev.cylc.overrideAttrs {
              src = pkgs.fetchFromGitHub {
                owner = "heywoodlh-bot";
                repo = "tree-sitter-cylc";
                rev = "53d051db1d527debe905f5ad1a7c05d2fb393bd6";
                hash = "sha256-Mllpfigv2i0sG1nQ55/ooR1q4HS3bJPIgjN9XyZC3Ec=";
              };
            };
          })
        ];
      };

      helixConf = pkgs.stdenv.mkDerivation {
        name = "config.toml";
        builder = pkgs.bash;
        args = ["-c" "${pkgs.coreutils}/bin/cp ${myConfig} $out"];
      };
    in {
      packages = rec {
        helix-config = helixConf;
        helix-wrapper = pkgs.writeShellScriptBin "hx" ''
          PATH="${pkgs.nix}/bin:${pkgs.nil}/bin:$PATH"
          mkdir -p ~/.config/helix/themes
          cp -f ${self}/themes/heywoodlh.toml ~/.config/helix/themes
          ${helixPkg}/bin/hx -c ${helixConf} $@
        '';
        helix = helixPkg;
        default = helix-wrapper;
      };

      formatter = pkgs.alejandra;
    });
}
