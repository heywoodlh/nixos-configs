{ config, pkgs, lib, ... }:

with lib;

let
  cfg = config.heywoodlh.home.llm;
in {
  options = {
    heywoodlh.home.llm = {
      enable = mkOption {
        default = false;
        description = ''
          Enable heywoodlh llm configuration.
        '';
        type = types.bool;
      };
      # wait until ollama + tools better supports intel gpus
      #homelab = mkOption {
      #  default = false;
      #  description = ''
      #    Enable heywoodlh homelab-dependent configuration.
      #    Will only be useful to author.
      #  '';
      #  type = types.bool;
      #};
      #model = mkOption {
      #  default = "qwen3:8b";
      #  description = ''
      #    Default Ollama model to use for codex.
      #  '';
      #  type = types.str;
      #};
    };
  };

  config = let
    #myCodex = pkgs.writeShellScriptBin "codex" ''
    #  ${pkgs.codex}/bin/codex -p myollama $@
    #'';
    #url = if cfg.homelab
    #  then "http://ollama.barn-banana.ts.net:11434"
    #  else "http://localhost:11434";
  in mkIf cfg.enable {
    home.packages = with pkgs; [
      codex
      #myCodex
    ];
    #home.file.".codex/config.toml" = {
    #  enable = false; wait until ollama better supports Intel GPUs
    #  text = ''
    #    [model_providers.myollama]
    #    name = "myollama"
    #    base_url = "${url}/v1"
    #    wire_api = "responses"

    #    [profiles.myollama]
    #    model_provider = "myollama"
    #    model = "${cfg.model}"
    #  '';
    #};
  };
}
