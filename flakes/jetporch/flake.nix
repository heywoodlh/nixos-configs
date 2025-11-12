{
  description = "workstation configuration for non-nixOS";

  inputs.nixpkgs.url = "github:NixOS/nixpkgs";
  inputs.flake-utils.url = "github:numtide/flake-utils";
  inputs.jetporch-nixpkgs.url = "github:heywoodlh/nixpkgs/jetporch-init";
  inputs.nixos-configs.url = "github:heywoodlh/nixos-configs";

  outputs = inputs @ {
    self,
    nixpkgs,
    flake-utils,
    jetporch-nixpkgs,
    nixos-configs,
  }:
    flake-utils.lib.eachDefaultSystem (system: let
      pkgs = nixpkgs.legacyPackages.${system};
      jetporch = jetporch-nixpkgs.legacyPackages.${system}.jetporch;
    in {
      packages = {
        ubuntu-22-desktop = pkgs.writeShellScriptBin "workstation" ''
          ${jetporch}/bin/jetp local -p ${self}/workstation/deploy.yml --extra-vars '{"release": "release-22.05", "nixos-configs": "${nixos-configs}"}'
        '';
      };
      devShell = pkgs.mkShell {
        name = "jetporch";
        buildInputs = [
          jetporch
        ];
      };
      formatter = pkgs.alejandra;
    });
}
