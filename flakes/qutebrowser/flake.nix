{
  description = "heywoodlh qutebrowser flake";

  inputs = {
    flake-utils.url = "github:numtide/flake-utils";
    nord-qutebrowser = {
      url = "github:Linuus/nord-qutebrowser";
      flake = false;
    };
  };

  outputs = { self, nixpkgs, flake-utils, nord-qutebrowser, }:
    flake-utils.lib.eachDefaultSystem (system:
    let
      pkgs = nixpkgs.legacyPackages.${system};
      config = pkgs.writeText "config.py" ''
        config.load_autoconfig(False)
        c.colors.webpage.darkmode.enabled = True
        c.window.hide_decoration = True
        c.aliases['pip'] = "spawn ${pkgs.mpv}/bin/mpv --no-border --cache=auto --force-window=immediate --auto-window-resize=no --ontop --on-all-workspaces --save-position-on-quit --watch-later-dir='/tmp/mpv/.cache/mpv' --autofit-larger='25%x40%' --ytdl-format='bestvideo[height<=?1080][fps<=?30][vcodec!=?vp9]+bestaudio/best' --geometry='-10-50' --focus-on=never --profile=fast --audio-buffer=1 --cache=yes --demuxer-max-bytes=123400KiB --demuxer-readahead-secs=5 --cache-pause-wait=15 --cache-pause-initial=yes --hwdec=yes {url}"
        c.aliases['pip-hint'] = "hint links spawn ${pkgs.mpv}/bin/mpv --no-border --cache=auto --force-window=immediate --auto-window-resize=no --ontop --on-all-workspaces --save-position-on-quit --watch-later-dir='/tmp/mpv/.cache/mpv' --autofit-larger='25%x40%' --ytdl-format='bestvideo[height<=?1080][fps<=?30][vcodec!=?vp9]+bestaudio/best' --geometry='-10-50' --focus-on=never --profile=fast --audio-buffer=1 --cache=yes --demuxer-max-bytes=123400KiB --demuxer-readahead-secs=5 --cache-pause-wait=15 --cache-pause-initial=yes --hwdec=yes {hint-url}"
        c.url.searchengines['aw'] = "https://wiki.archlinux.org/?search={}"
        c.url.searchengines['g'] = "https://www.google.com/search?hl=en&q={}"
        c.url.searchengines['k'] = "https://kagi.com/search?q={}"
        c.url.searchengines['nw'] = "https://wiki.nixos.org/index.php?search={}"
        c.url.searchengines['w'] = "https://en.wikipedia.org/wiki/Special:Search?search={}&go=Go&ns0=1"
        # Nord theme
        config.source('${nord-qutebrowser}/nord-qutebrowser.py')
      '';
      standalone-config = pkgs.writeText "config.py" ''
        # Source additional config if exists
        import os.path
        homedir = os.path.expanduser("~")
        baseConf = homedir + "/.qutebrowser/config.py"
        if os.path.isfile(baseConf):
          config.source(baseConf)
        config.source("${config}")
      '';
    in {
      packages = rec {
        qutebrowser = pkgs.writeShellScriptBin "qutebrowser" ''
          ${pkgs.qutebrowser-qt5}/bin/qutebrowser -C ${standalone-config} $@
        '';
        qutebrowser-config = pkgs.stdenv.mkDerivation {
          name = "config.py";
          builder = pkgs.bash;
          args = [ "-c" "${pkgs.coreutils}/bin/cp ${config} $out" ];
        };
        default = qutebrowser;
        };
      }
    );
}
