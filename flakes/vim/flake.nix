{
  description = "heywoodlh vim config";
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };
  outputs = { self, nixpkgs, flake-utils, }: flake-utils.lib.eachDefaultSystem (system:
    let
      pkgs = import nixpkgs {
        inherit system;
        config.allowUnfree = true;
      };
      mods = pkgs.callPackage ./settings {};
      myVim = pkgs.callPackage ./default.nix {
        inherit mods;
      };
    in {
      packages = rec {
        vim = myVim;
        default = vim;
      };
    }
  );
}
