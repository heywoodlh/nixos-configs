{
  description = "Tabby Terminal Emulator Flake";

  inputs.nixpkgs.url = "github:NixOS/nixpkgs";
  inputs.flake-utils.url = "github:numtide/flake-utils";

  outputs =
    inputs@{
      self,
      nixpkgs,
      flake-utils,
    }:
    flake-utils.lib.eachDefaultSystem (
      system:
      let
        pkgs = nixpkgs.legacyPackages.${system};
        tabbyPkg = pkgs.callPackage ./tabby.nix {};
        confDir = if pkgs.stdenv.isDarwin then "$HOME/Library/Application\ Support/tabby" else "$HOME/.config/tabby";
        conf = ./config.yaml;
        tabbyWrapper = pkgs.writeShellScriptBin "tabby" ''
          mkdir -p "${confDir}"
          cp -f ${conf} "${confDir}/config.yaml"
          ${tabbyPkg}/bin/tabby $@
        '';
      in
      {
        packages = rec {
          tabby-wrapper = tabbyWrapper;
          tabby = tabbyPkg;
          default = tabby;
        };

        formatter = pkgs.nixfmt-rfc-style;
      }
    );
}
