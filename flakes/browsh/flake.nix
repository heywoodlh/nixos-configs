{
  description = "Browsh Flake";

  inputs.nixpkgs.url = "github:NixOS/nixpkgs";
  inputs.flake-utils.url = "github:numtide/flake-utils";

  outputs =
    inputs@{
      self,
      nixpkgs,
      flake-utils,
    }:
    flake-utils.lib.eachDefaultSystem (system: let
      pkgs = nixpkgs.legacyPackages.${system};
      browshPackage = pkgs.callPackage ./browsh.nix {};
      browshWrapperBin = pkgs.writeShellScriptBin "browsh" ''
        PATH="${pkgs.bash}/bin:${pkgs.coreutils}/bin:${pkgs.ps}/bin:$PATH"
        ${browshPackage}/bin/browsh --firefox.path ${pkgs.firefox-esr}/bin/firefox-esr $@ 
      '';
    in {
      packages = rec {
        browshWrapper = if pkgs.stdenv.isLinux then browshWrapperBin else null;
        browsh = browshPackage;
        default = if pkgs.stdenv.isLinux then browshWrapper else browsh;
      };
      formatter = pkgs.nixfmt-rfc-style;
    });
}
