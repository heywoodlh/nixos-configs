{ config, lib, pkgs, ... }:

with lib;
let
  cfg = config.heywoodlh.home.git;
in {
  options = {
    heywoodlh.home.git = {
      enable = mkOption {
        default = false;
        description = ''
          Enable heywoodlh git configuration.
        '';
        type = types.bool;
      };
      email = mkOption {
        default = "git@heywoodlh.io";
        description = ''
          Email for git operations.
        '';
        type = types.str;
      };
      name = mkOption {
        default = "Spencer Heywood";
        description = ''
          Name for git operations.
        '';
        type = types.str;
      };
    };
  };

  config = mkIf cfg.enable {
    home.packages = with pkgs; [
      git-bug
    ];

    programs.git = {
      enable = true;
      package = pkgs.git;

      ignores = [
        # Direnv
        ".envrc"
        ".direnv"
      ];

      includes = [
        { path = "~/.gitconfig"; }
      ];

      settings = {
        color.ui = "auto";

        core = {
          autocrlf = "input";
          editor = if config.heywoodlh.home.helix.enable then "hx" else "vim";
          pager = "${pkgs.less}/bin/less -+F";
          whitespace = "cr-at-eol";
        };

        diff.renames = "copies";

        format.pretty = "%Cred%h%Creset -%C(yellow)%d%Creset %s %Cgreen(%cd) %C(bold blue)<%an>%Creset";

        merge = {
          conflictstyle = "diff3";
          tool = "vimdiff";
        };

        mergetool.prompt = true;

        pull.ff = "only";

        push.default = "simple";

        user = {
          email = cfg.email;
          name = cfg.name;
        };
      };
    };
  };
}
