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
      platform = mkOption {
        default = "";
        description = ''
          Enable one of the following platforms:
          - "intel"
          - "nvidia"
          - "amd"
          - "homelab"

          The "homelab" option is only useful to author -- all other options will enable Ollama locally with support for the chosen platform.
        '';
        type = types.nullOr types.str;
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
    myCodex = pkgs.writeShellScriptBin "codex" ''
      ${pkgs.codex}/bin/codex -p myollama $@
    '';
    url = if (cfg.platform == "homelab")
      then "http://ollama.barn-banana.ts.net:11434"
      else "http://localhost:11434";
    ollamaPkg = if (cfg.platform != "homelab") then config.services.ollama.package else pkgs.ollama;
    myOllamaPull = pkgs.writeShellScript "ollama-pull" ''
      # Loop 3 times until model is pulled
      (r=3;while ! ${ollamaPkg}/bin/ollama list &>/dev/null ; do ((--r))||exit;sleep 60;done) && ${ollamaPkg}/bin/ollama pull ${cfg.model}
    '';
    myOllama = pkgs.writeShellScriptBin "ollama" ''
      [[ -z "$OLLAMA_HOST" ]] && export OLLAMA_HOST="${url}"
      ${pkgs.ollama}/bin/ollama $@
    '';
  in mkIf cfg.enable {
    home.packages = [
      myCodex
    ] ++ lib.optionals (cfg.platform == "homelab") [
      myOllama
    ];

    systemd.user.services.ollama-pull = {
      Unit = {
        Description = "Automatically pull Ollama images";
        After = [ "ollama.service" ];
      };

      Service = {
        ExecStart = "${myOllamaPull}";
        Environment = if (cfg.platform != "homelab") then config.systemd.user.services.ollama.Service.Environment else [
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
        EnvironmentVariables = if (cfg.platform != "homelab") then config.launchd.agents.ollama.config.EnvironmentVariables else {
          OLLAMA_HOST = url;
        };
        KeepAlive = {
          Crashed = true;
          SuccessfulExit = true;
        };
        ProcessType = "Background";
      };
    };

    services.ollama = {
      enable = (cfg.platform != "homelab");
      acceleration = let
        platform = if cfg.platform == "nvidia" then "cuda"
          else if cfg.platform == "amd" then "rocm" else null;
      in lib.optionalString (platform != "") platform;
      environmentVariables = lib.optionalAttrs (cfg.platform != "" && cfg.platform != "homelab") {
        OLLAMA_VULKAN = lib.optionalString (cfg.platform == "intel") "1";
      };
    };

    home.file.".codex/config.toml".text = ''
      [model_providers.myollama]
      name = "myollama"
      base_url = "${url}/v1"
      wire_api = "responses"

      [profiles.myollama]
      model_provider = "myollama"
      model = "${cfg.model}"
    '';
  };
}
