{ config, lib, pkgs, ... }:

with lib;
with lib.types;

let
  cfg = config.heywoodlh.darwin.lmstudio;
in {
  options.heywoodlh.darwin.lmstudio = {
    enable = mkOption {
      default = false;
      description = "Enable LM Studio configuration.";
      type = bool;
    };
    user = mkOption {
      default = config.heywoodlh.darwin.defaults.user.name;
      description = "User to configure LM Studio for.";
      type = str;
    };
  };

  config = mkIf cfg.enable {
    homebrew = {
      enable = true;
      casks = [
        "lm-studio"
      ];
    };
    home-manager.users.${cfg.user} = {
      home.packages = [
        (pkgs.writeShellScriptBin "lms" ''
          "/Applications/LM Studio.app/Contents/Resources/app/.webpack/lms" $@
        '')
      ];
      heywoodlh.home.llm = {
        enable = true;
        lmstudio.enable = true;
      };
    };
  };
}
