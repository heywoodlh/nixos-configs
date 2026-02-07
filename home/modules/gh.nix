{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.heywoodlh.home.github-cli;
  # For some reason, long commands get wrapped weirdly
  # This works around that by wrapping in script
  issue = pkgs.writeShellScript "ghi" ''
    ${config.programs.gh.package}/bin/gh issue create --editor
  '';
  pr = pkgs.writeShellScript "ghp" ''
    ${config.programs.gh.package}/bin/gh pr create --editor
  '';
in {
  options = {
    heywoodlh.home.github-cli = mkOption {
      default = false;
      description = ''
        Enable heywoodlh home-manager GitHub CLI configuration.
      '';
      type = types.bool;
    };
  };

  config = mkIf cfg {
    programs.gh = {
      enable = true;
      extensions = with pkgs; [
        gh-copilot
        gh-dash
        gh-eco
        gh-markdown-preview
      ];
      settings = {
        git_protocol = "ssh";
        editor = if config.heywoodlh.home.helix.enable then
          "${config.programs.helix.package}/bin/hx"
        else
          "${pkgs.neovim}/bin/nvim"
        ;
      };
    };

    programs.gh-dash = {
      enable = true;
      settings = {
        confirmQuit = true;
        showAuthorIcons = true;
        defaults.view = "issues";
        prSections = [
          {
            title = "prs";
            filters = "is:open author:@me";
          }
          {
            title = "my assigned prs";
            filters = "assignee:@me is:open sort:updated-desc";
          }
          {
            title = "all open prs";
            filters = "is:open sort:updated-desc";
          }
          {
            title = "all prs";
            filters = "sort:updated-desc";
          }
        ];
        keybindings = {
          issues = [
            {
              key = "C";
              name = "create new issue";
              command = "${issue}";
            }
          ];
          prs = [
            {
              key = "C";
              name = "create new PR";
              command = "${pr}";
            }
          ];
        };
        issuesSections = [
          {
            title = "my issues";
            filters = "author:@me is:open sort:updated-desc";
          }
          {
            title = "my assigned issues";
            filters = "assignee:@me is:open sort:updated-desc";
          }
          {
            title = "all open issues";
            filters = "is:open sort:updated-desc";
          }
          {
            title = "all issues";
            filters = "sort:updated-desc";
          }
        ];
      };
    };
  };
}
