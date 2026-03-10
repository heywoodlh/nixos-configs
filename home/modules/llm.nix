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
      homelab = mkOption {
        default = false;
        description = ''
          This option is only useful to author.
        '';
        type = types.bool;
      };
      model = mkOption {
        default = "llama3.1:8b";
        description = ''
          Default Ollama model to use for codex.
        '';
        type = types.str;
      };
    };
  };

  config = let
    url = if (cfg.homelab)
      then "http://ollama.barn-banana.ts.net:11434"
      else "http://localhost:11434";
    myCodexOllama = pkgs.writeShellScriptBin "codex-ollama" ''
      ${pkgs.codex}/bin/codex --oss --local-provider ollama --model ${cfg.model} $@
    '';
    ollamaPkg = if (cfg.homelab == false) then config.services.ollama.package else pkgs.ollama;
    myOllamaPull = pkgs.writeShellScript "ollama-pull" ''
      # Loop 3 times until model is pulled
      (r=3;while ! ${ollamaPkg}/bin/ollama list &>/dev/null ; do ((--r))||exit;sleep 60;done) && ${ollamaPkg}/bin/ollama pull ${cfg.model}
    '';
    myOllama = pkgs.writeShellScriptBin "ollama" ''
      [[ -z "$OLLAMA_HOST" ]] && export OLLAMA_HOST="${url}"
      ${ollamaPkg}/bin/ollama $@
    '';
  in mkIf cfg.enable {
    home.packages = with pkgs; [
      codex
      myCodexOllama
    ] ++ lib.optionals (cfg.homelab) [
      myOllama
    ];

    systemd.user.services.ollama-pull = {
      Unit = {
        Description = "Automatically pull Ollama images";
        After = [ "ollama.service" ];
      };

      Service = {
        ExecStart = "${myOllamaPull}";
        Environment = if (cfg.homelab == false) then config.systemd.user.services.ollama.Service.Environment else [
          "OLLAMA_HOST=${url}"
        ];
      };

      Install = {
        WantedBy = [ "default.target" ];
      };
    };

    launchd.agents.ollama-pull = {
      enable = true;
      config = {
        ProgramArguments = [
          "${myOllamaPull}"
        ];
        EnvironmentVariables = if (cfg.homelab == false) then config.launchd.agents.ollama.config.EnvironmentVariables else {
          OLLAMA_HOST = url;
        };
        KeepAlive = {
          Crashed = true;
          SuccessfulExit = true;
        };
        ProcessType = "Background";
      };
    };

    services.ollama = lib.optionalAttrs (cfg.homelab == false) {
      enable = true;
      environmentVariables = {
        OLLAMA_VULKAN = "1";
      };
    };
  };
}
