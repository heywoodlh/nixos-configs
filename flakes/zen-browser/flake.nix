{
  description = "Zen Browser Flake";

  inputs.nixpkgs.url = "github:NixOS/nixpkgs";
  inputs.flake-utils.url = "github:numtide/flake-utils";
  inputs.zen-browser.url = "github:MarceColl/zen-browser-flake";

  outputs =
    inputs@{
      self,
      nixpkgs,
      flake-utils,
      zen-browser,
    }:
    flake-utils.lib.eachDefaultSystem (
      system:
      let
        pkgs = nixpkgs.legacyPackages.${system};
        zenBrowser = if pkgs.stdenv.isDarwin then pkgs.callPackage ./zen.nix {}
        else zen-browser.packages.${system}.default;
        zenWrapper = pkgs.writeShellScriptBin "zen" ''
          mkdir -p $HOME/Documents/zen/Profiles/main
          ${zenBrowser}/bin/zen --profile $HOME/Documents/zen/Profiles/main
        '';
      in
      {
        packages = rec {
          zen-wrapper = zenWrapper;
          zen-browser = zenBrowser;
          default = if pkgs.stdenv.isDarwin then zen-wrapper else zen-browser;
        };

        formatter = pkgs.nixfmt-rfc-style;
      }
    );
}
