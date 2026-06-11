{ config, lib, pkgs, gh-gitignore, ... }:

with lib;
let
  cfg = config.heywoodlh.home.git;
  readIgnoreFile =
    path:
    builtins.filter (line: line != "" && !lib.hasPrefix "#" line && !lib.hasPrefix "Icon[" line) (
      lib.splitString "\n" (builtins.readFile path)
    );
  gitignore = gh-gitignore;
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

      ignores =
        readIgnoreFile "${gitignore}/Nix.gitignore"
        ++ readIgnoreFile "${gitignore}/Global/Linux.gitignore"
        ++ readIgnoreFile "${gitignore}/Global/macOS.gitignore"
        ++ readIgnoreFile "${gitignore}/Global/Vim.gitignore"
        ++ readIgnoreFile "${gitignore}/Global/VisualStudioCode.gitignore"
        ++ readIgnoreFile "${gitignore}/Global/Xcode.gitignore"
        ++ readIgnoreFile "${gitignore}/Global/Agents.gitignore"
        ++ [
          # Direnv
          ".envrc"
          ".direnv"
          ".claude"
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
