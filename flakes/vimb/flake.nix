{
  description = "heywoodlh vimb flake";

  inputs.flake-utils.url = "github:numtide/flake-utils";
  inputs.nixgl.url = "github:nix-community/nixGL";

  outputs = { self, nixpkgs, flake-utils, nixgl, }:
    flake-utils.lib.eachDefaultSystem (system:
    let
      pkgs = import nixpkgs {
        inherit system;
        config.allowUnfree = true;
        overlays = [ nixgl.overlay ];
      };

      config = pkgs.writeText "config" ''
        set home-page=github.com
        set download-path=~/Downloads/
        set editor-command=${pkgs.vim}/bin/gvim -f %s
        set input-autohide=false
        set spell-checking=true
        set spell-checking-languages=en
        set webgl=true
        set incsearch=true
        set show-titlebar=false
        set dark-mode=on
        shortcut-add ddg=https://duckduckgo.com/?q=$0
        shortcut-default ddg
      '';
    in {
      packages = rec {
        vimb = pkgs.writeShellScriptBin "vimb" ''
          ${pkgs.vimb}/bin/vimb --config ${config}
        '';
        vimb-gl = pkgs.writeShellScriptBin "vimb" ''
          ${pkgs.nixgl.auto.nixGLDefault}/bin/nixGL ${pkgs.vimb}/bin/vimb --config ${config}
        '';
        default = vimb;
        };
      }
    );
}
