{ config, lib, pkgs, ... }:

with lib;
with lib.types;

let
  cfg = config.heywoodlh.home.onepassword;
in {
  options = {
    heywoodlh.home.onepassword = {
      enable = mkOption {
        default = false;
        description = ''
          Enable heywoodlh 1password GUI configuration.
        '';
        type = bool;
      };
      gpu = mkOption {
        default = true;
        description = ''
          Enable GPU acceleration for 1Password GUI.
        '';
        type = bool;
      };
      extraArgs = mkOption {
        default = "";
        description = ''
          Extra arguments to pass 1Password GUI executable.
        '';
        type = str;
      };
      package = mkOption {
        default = pkgs._1password-gui;
        description = ''
          1Password GUI package to use.
        '';
        type = package;
      };
      wrapper = mkOption {
        default = pkgs.writeShellScriptBin "1password-gui-wrapper" ''
          ${cfg.package}/bin/1password ${cfg.extraArgs} $@
        '';
        description = ''
          1Password GUI wrapper to reference throughout heywoodlh configurations.
        '';
        type = package;
      };
    };
  };

  config = mkIf cfg.enable {
    heywoodlh.home.onepassword.extraArgs = optionalString (cfg.gpu == false) "--disable-gpu";
    home.packages = [
      cfg.wrapper
    ];
  };
}
