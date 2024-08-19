{ config, lib, pkgs, qutebrowser, myFlakes, ... }:

with lib;

let
  cfg = config.heywoodlh.home.qutebrowser;
  system = pkgs.system;
  homeDir = config.home.homeDirectory;
  qutebrowser-config = myFlakes.packages.${system}.qutebrowser-config;
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
      extraConfig = ''
        config.source("${qutebrowser-config}")
      '';
    };

    home.file.".qutebrowser/userscripts/qute-1pass" = mkIf cfg.enable1Pass {
      source = "${qutebrowser}/misc/userscripts/qute-1pass";
      executable = true;
    };
  };
}
