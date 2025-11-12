{
  description = "heywoodlh git config";

  inputs.flake-utils.url = "github:numtide/flake-utils";

  outputs = { self, nixpkgs, flake-utils, ... }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = nixpkgs.legacyPackages.${system};
        gitignore = pkgs.writeText "gitignore" ''
# Direnv
.envrc
.direnv

# Terraform
**/.terraform/*
*.tfstate
*.tfstate.*
crash.log
crash.*.log
*.tfvars
*.tfvars.json
override.tf
override.tf.json
*_override.tf
*_override.tf.json
.terraformrc
terraform.rc
        '';
        gitconfig = pkgs.writeText "gitconfig" ''
[color]
  ui = "auto"

[core]
  autocrlf = "input"
  editor = "vim"
  pager = "${pkgs.less}/bin/less -+F"
  whitespace = "cr-at-eol"
  excludesFile = "${gitignore}"

[diff]
  renames = "copies"

[format]
  pretty = "%Cred%h%Creset -%C(yellow)%d%Creset %s %Cgreen(%cd) %C(bold blue)<%an>%Creset"

[merge]
  conflictstyle = "diff3"
  tool = "vimdiff"

[mergetool]
  prompt = "true"

[pull]
  ff = "only"

[push]
  default = "simple"

[include]
  path = ~/.gitconfig
  path = ~/.config/git/config

[user]
  email = "github@heywoodlh.io"
  name = "Spencer Heywood"

        '';
      in {
        packages = rec {
          git = pkgs.writeShellScriptBin "git" ''
            export GIT_CONFIG_GLOBAL=${gitconfig}
            ${pkgs.git}/bin/git "$@"
          '';
          default = git;
        };
      }
    );
}
