{
  description = "ansible configurations";

  inputs.nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";
  inputs.flake-utils.url = "github:numtide/flake-utils";

  outputs = inputs @ {
    self,
    nixpkgs,
    flake-utils,
  }:
    flake-utils.lib.eachDefaultSystem (system: let
      pkgs = nixpkgs.legacyPackages.${system};
      installCollections = ''
        sudo ${pkgs.ansible}/bin/ansible-galaxy install -r ${self}/requirements.yml
      '';
      test-sh = pkgs.writeShellScriptBin "test.sh" ''
        ${self}/test.sh $@
      '';
    in {
      packages = {
        workstation = pkgs.writeShellScriptBin "workstation" ''
          export LC_ALL="C.UTF-8"
          ${installCollections}
          sudo ${pkgs.ansible}/bin/ansible-playbook --connection=local ${self}/workstation/workstation.yml
        '';
        server = pkgs.writeShellScriptBin "server" ''
          export LC_ALL="C.UTF-8"
          ${installCollections}
          sudo ${pkgs.ansible}/bin/ansible-playbook --connection=local ${self}/server/standalone.yml
        '';
        tester = test-sh;
      };
      devShell = pkgs.mkShell {
        name = "ansible";
        buildInputs = with pkgs; [
          ansible
          test-sh
        ];
      };
      formatter = pkgs.alejandra;
    });
}
