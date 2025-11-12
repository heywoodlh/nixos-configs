{
  description = "ansible configurations";

  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
  inputs.flake-utils.url = "github:numtide/flake-utils";
  inputs.nixos-configs.url = "github:heywoodlh/nixos-configs";

  outputs = inputs @ {
    self,
    nixpkgs,
    flake-utils,
    nixos-configs,
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
          ansible-language-server
          test-sh
        ];
      };
      formatter = pkgs.alejandra;
    });
}
