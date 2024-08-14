{ config, lib, pkgs, qutebrowser, ... }:

with lib;

let
  cfg = config.heywoodlh.home.qutebrowser;
  system = pkgs.system;
  homeDir = config.home.homeDirectory;
  qutebrowserNord = pkgs.fetchFromGitHub {
    owner = "Linuus";
    repo = "nord-qutebrowser";
    rev = "c7f89c0991bdb8e02ede67356355cd9ae891d2be";
    hash = "sha256-Fa1BFflkDp9AH4osK1pFti9KqJ5wL/f0aQ9BvpNVMWI=";
  };
in {
  options = {
    heywoodlh.home.qutebrowser = {
      enable = mkOption {
        default = false;
        description = ''
          Enable heywoodlh qutebrowser config.
        '';
        type = types.bool;
      };
      enable1Pass = mkOption {
        default = false;
        description = ''
          Enable qutebrowser 1Pass userscript.
        '';
        type = types.bool;
      };
    };
  };

  config = mkIf cfg.enable {
    home.packages = with pkgs; [
      mpv
    ];
    programs.qutebrowser = {
      enable = true;
      package = if pkgs.stdenv.isDarwin then
        pkgs.runCommand "qutebrowser-0.0.0" { } "mkdir $out"
      else
        pkgs.qutebrowser;
      quickmarks = {
        home-manager-config = "https://nix-community.github.io/home-manager/options.xhtml";
        nix-darwin-config = "https://daiderd.com/nix-darwin/manual/index.html#sec-options";
        nixos-config = "https://search.nixos.org/options?";
      };
      searchEngines = {
        w = "https://en.wikipedia.org/wiki/Special:Search?search={}&go=Go&ns0=1";
        aw = "https://wiki.archlinux.org/?search={}";
        nw = "https://wiki.nixos.org/index.php?search={}";
        g = "https://www.google.com/search?hl=en&q={}";
        k = "https://kagi.com/search?q={}";
      };
      settings = {
        colors.webpage.darkmode.enabled = true;
        window.hide_decoration = true;
        content.proxy_dns_requests = false;
      };
      extraConfig = ''
        # Nord theme
        config.source('${qutebrowserNord}/nord-qutebrowser.py')
      '';
      aliases = let
        mpvOs = if pkgs.stdenv.isDarwin then "--hwdec=yes" else "";
        mpvExec = "${pkgs.mpv}/bin/mpv --no-border --cache=auto --force-window=immediate --auto-window-resize=no --ontop --on-all-workspaces --save-position-on-quit --watch-later-dir='${homeDir}/.cache/mpv' --autofit-larger='25%x40%' --ytdl-format='bestvideo[height<=?1080][fps<=?30][vcodec!=?vp9]+bestaudio/best' --geometry='-10-50' --focus-on=never --profile=fast --audio-buffer=1 --cache=yes --demuxer-max-bytes=123400KiB --demuxer-readahead-secs=5 --cache-pause-wait=15 --cache-pause-initial=yes ${mpvOs}";
      in {
        # picture-in-picture
        pip = "spawn ${mpvExec} {url}";
        pip-hint = "hint links spawn ${mpvExec} {hint-url}";
      };
    };

    home.file.".qutebrowser/userscripts/qute-1pass" = mkIf cfg.enable1Pass {
      source = "${qutebrowser}/misc/userscripts/qute-1pass";
      executable = true;
    };
  };
}
