{
  description = "heywoodlh nushell flake";

  inputs.flake-utils.url = "github:numtide/flake-utils";

  outputs = { self, nixpkgs, flake-utils }:
    flake-utils.lib.eachDefaultSystem (system:
    let
      pkgs = nixpkgs.legacyPackages.${system};
    in {
      packages = rec {
        nushell = pkgs.writeShellScriptBin "nu" ''
            ${pkgs.nushell}/bin/nu --env-config ${./env.nu} --config ${./config.nu}
          '';
        default = nushell;
        };
      }
    );
}
