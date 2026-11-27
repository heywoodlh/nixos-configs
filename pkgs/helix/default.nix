{
  pkgs,
  helix-src,
  ...
}: let
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

  helixPkg = helix-src.packages.${pkgs.stdenv.hostPlatform.system}.helix.override {
    grammarOverlays = [
      # helix-src's grammars still use deprecated stdenv.isLinux; re-set fixupPhase without it
      (_final: prev:
        pkgs.lib.mapAttrs
        (_: drv:
          if pkgs.lib.isDerivation drv
          then drv.overrideAttrs (_: {
            fixupPhase = pkgs.lib.optionalString pkgs.stdenv.hostPlatform.isLinux ''
              runHook preFixup
              $STRIP $out/$SHARED_LIB
              runHook postFixup
            '';
          })
          else drv)
        prev)
      (_final: prev: {
        perl = prev.perl.overrideAttrs (old: {
          FLAGS = old.FLAGS ++ ["-std=gnu17"];
        });
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
  helix-config = helixConf;
  helix-wrapper = pkgs.writeShellScriptBin "hx" ''
    PATH="${pkgs.nix}/bin:${pkgs.nil}/bin:$PATH"
    mkdir -p ~/.config/helix/themes
    cp -f ${./themes/heywoodlh.toml} ~/.config/helix/themes
    ${helixPkg}/bin/hx -c ${helixConf} $@
  '';
  helix = helixPkg;
}
