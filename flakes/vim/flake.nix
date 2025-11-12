{
  description = "heywoodlh vim config";
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    flake-utils.url = "github:numtide/flake-utils";
    mcphub = {
      url = "github:ravitemer/mcp-hub";
      flake = false;
    };
    mcphub-nvim = {
      url = "github:ravitemer/mcphub.nvim";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };
  outputs = { self, nixpkgs, flake-utils, mcphub-nvim, mcphub, }: flake-utils.lib.eachDefaultSystem (system:
    let
      pkgs = import nixpkgs {
        inherit system;
        config.allowUnfree = true;
      };
      mods = pkgs.callPackage ./settings {
        inherit mcphub;
        inherit mcphub-nvim;
      };
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
