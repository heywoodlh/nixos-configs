{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.heywoodlh.home.aerc;
  aerc-html-filter = pkgs.writeShellScript "html" ''
    exec ${pkgs.w3m}/bin/w3m \
      -T text/html \
      -cols $(${pkgs.ncurses}/bin/tput cols) \
      -dump \
      -o display_image=false \
      -o display_link_number=true
  '';
in {
  options = {
    heywoodlh.home.aerc = {
      enable = mkOption {
        default = false;
        description = ''
          Enable heywoodlh aerc configuration.
        '';
        type = types.bool;
      };
      accounts = mkOption {
        default = { };
        example = {
          work = {
            source = "maildir://~/Maildir/work";
          };
        };
        description = ''
          Accounts added to `programs.aerc.extraAccounts`.
        '';
        type = types.attrsOf (types.attrsOf types.anything);
      };
    };
  };

  config = mkIf cfg.enable {
    heywoodlh.home.helix.enable = true;

    programs.aerc.enable = true;
    programs.aerc.extraConfig = {
      general = {
        unsafe-accounts-conf = true;
        editor = "hx";
      };
      filters = {
        "text/html" = "${aerc-html-filter}";
        "text/plain" = "${pkgs.coreutils}/bin/fold -w 80";
      };
      ui = {
        styleset-name = "catppuccin-macchiato";
      };
    };
    programs.aerc.stylesets.catppuccin-macchiato = {
      global = {
        "*.default" = true;

        "default.fg" = "#cad3f5";

        "error.fg" = "#ed8796";
        "warning.fg" = "#eed49f";
        "success.fg" = "#a6da95";

        "border.fg" = "#363a4f";

        "title.fg" = "#cad3f5";
        "title.bg" = "#363a4f";
        "title.bold" = true;

        "header.fg" = "#8aadf4";
        "header.bold" = true;

        "tab.fg" = "#8087a2";
        "tab.bg" = "#1e2030";
        "tab.selected.fg" = "#cad3f5";
        "tab.selected.bg" = "#363a4f";
        "tab.selected.bold" = true;

        "msglist_default.fg" = "#b8c0e0";
        "msglist_unread.fg" = "#cad3f5";
        "msglist_unread.bold" = true;
        "msglist_flagged.fg" = "#eed49f";
        "msglist_flagged.bold" = true;
        "msglist_deleted.dim" = true;
        "msglist_result.fg" = "#8aadf4";
        "msglist_result.bold" = true;
        "msglist_thread_context.dim" = true;
        "msglist_thread_folded.fg" = "#939ab7";
        "msglist_marked.fg" = "#24273a";
        "msglist_marked.bg" = "#c6a0f6";
        "msglist_gutter.fg" = "#494d64";
        "msglist_pill.fg" = "#24273a";
        "msglist_pill.bg" = "#b7bdf8";

        "msglist_*.selected.fg" = "#24273a";
        "msglist_*.selected.bg" = "#b7bdf8";
        "msglist_*.selected.bold" = true;

        "dirlist_*.selected.fg" = "#24273a";
        "dirlist_*.selected.bg" = "#b7bdf8";
        "dirlist_*.selected.bold" = true;

        "statusline_default.fg" = "#a5adcb";
        "statusline_default.bg" = "#363a4f";
        "statusline_error.fg" = "#ed8796";
        "statusline_error.bold" = true;
        "statusline_success.fg" = "#a6da95";
        "statusline_success.bold" = true;

        "selector_default.fg" = "#b8c0e0";
        "selector_focused.fg" = "#24273a";
        "selector_focused.bg" = "#b7bdf8";
        "selector_focused.bold" = true;
        "selector_chooser.fg" = "#c6a0f6";
        "selector_chooser.bold" = true;

        "completion_default.fg" = "#b8c0e0";
        "completion_*.bg" = "#363a4f";
        "completion_description.fg" = "#8087a2";
        "completion_pill.fg" = "#24273a";
        "completion_pill.bg" = "#b7bdf8";
        "completion_default.selected.fg" = "#24273a";
        "completion_default.selected.bg" = "#b7bdf8";
        "completion_default.selected.bold" = true;

        "part_switcher.bg" = "#363a4f";
        "part_filename.fg" = "#cad3f5";
        "part_filename.selected.fg" = "#24273a";
        "part_filename.selected.bg" = "#b7bdf8";
        "part_mimetype.fg" = "#939ab7";
        "part_mimetype.selected.fg" = "#24273a";
        "part_mimetype.selected.bg" = "#b7bdf8";

        "keyhint_default.bg" = "#363a4f";
        "keyhint_key.fg" = "#b7bdf8";
        "keyhint_desc.fg" = "#a5adcb";

        "spinner.fg" = "#b7bdf8";
      };
      viewer = {
        "url.fg" = "#8aadf4";
        "url.underline" = true;
        "header.fg" = "#8aadf4";
        "header.bold" = true;
        "signature.fg" = "#8087a2";
        "signature.dim" = true;
        "diff_meta.bold" = true;
        "diff_chunk.fg" = "#7dc4e4";
        "diff_chunk_func.fg" = "#7dc4e4";
        "diff_chunk_func.bold" = true;
        "diff_add.fg" = "#a6da95";
        "diff_del.fg" = "#ed8796";
        "diff_whitespace.bg" = "#ed8796";
        "quote_1.fg" = "#939ab7";
        "quote_2.fg" = "#8087a2";
        "quote_3.fg" = "#8aadf4";
        "quote_4.fg" = "#6e738d";
        "quote_x.fg" = "#6e738d";
        "code.fg" = "#a6da95";
      };
    };
    programs.aerc.extraAccounts = cfg.accounts;

    home.packages = with pkgs; [
      khard
    ];
  };
}
