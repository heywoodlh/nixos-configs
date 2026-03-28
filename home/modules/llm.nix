{ config, pkgs, lib, ... }:

with lib;

let
  cfg = config.heywoodlh.home.llm;
  homeDir = config.home.homeDirectory;
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
      copilot = mkOption {
        default = true;
        description = ''
          Enable GitHub Copilot.
        '';
        type = types.bool;
      };
    };
  };

  config = let
    url = if (cfg.homelab)
      then "http://ollama.barn-banana.ts.net:11434"
      else "http://localhost:11434";
    # Lightweight model to always pull
    model = "llama3.1:8b";
    myCodexOllama = pkgs.writeShellScriptBin "codex-ollama" ''
      ${pkgs.codex}/bin/codex --oss --local-provider ollama $@
    '';
    ollamaPkg = if (cfg.homelab == false) then config.services.ollama.package else pkgs.ollama;
    myOllamaPull = pkgs.writeShellScript "ollama-pull" ''
      # Loop 3 times until model is pulled
      (r=3;while ! ${ollamaPkg}/bin/ollama list &>/dev/null ; do ((--r))||exit;sleep 60;done) && ${ollamaPkg}/bin/ollama pull ${model}
    '';
    myOllama = pkgs.writeShellScriptBin "ollama" ''
      [[ -z "$OLLAMA_HOST" ]] && export OLLAMA_HOST="${url}"
      ${ollamaPkg}/bin/ollama $@
    '';
  in mkIf cfg.enable {
    home.packages = with pkgs; [
      myCodexOllama
      github-copilot-cli
    ] ++ lib.optionals (cfg.homelab) [
      myOllama
    ];

    heywoodlh.home.helix.ai = true;

    programs.codex = {
      enable = true;
      enableMcpIntegration = true;
      settings = {
        features = {
          streamable_shell = true;
          rmcp_client = true;
          unified_exec = true;
          view_image_tool = true;
          shell_tool = true; # enable `/shell`
          apply_patch_freeform = true; # freeform patch syntax
        };
        history = {
          persistence = "save-all";
        };
        shell_environment_policy = {
          "inherit" = "all";
          "set" = {
            CODEX_AGENT = "1";
          };
        };
        model = "";
        model_provider = "github-copilot"; # use copilot by default
        model_providers = {
          ollama = {
            name = "ollama";
            base_url = "${url}/v1";
            wire_api = "responses";
          };
        };
        sandbox_mode = "workspace-write";
        sandbox_workspace_write = {
          writable_roots = [
            "${homeDir}/.cache/sccache"
            "${homeDir}/.cache/nix"
            "/nix"
            "/nix/var/nix"
            "${homeDir}/.cache/pre-commit"
            # Allow Codex sandboxed pre-commit runs to write their hook log.
            "${homeDir}/.cache/pre-commit/pre-commit.log"
          ];
          network_access = true;
          exclude_tmpdir_env_var = false;
          exclude_slash_tmp = false;
        };
        # The UI can pick a profile via the `/select_profile` command or by setting
        profiles = {
          llama3 = {
            model = "${model}";
            model_provider = "ollama";
            features = {
              web_search_request = false;
            };
          };
        };
      };
    };

    programs.opencode = {
      enable = true;
      enableMcpIntegration = true;
      settings = {
        # Disable default cloud providers
        "disabled_providers" = [
          "opencode"
        ];
        provider.ollama = {
          npm = "@ai-sdk/openai-compatible";
          name = "Ollama (local)";
          options = {
            baseURL = "${url}/v1";
          };
          models = {
            "${model}" = {
              name = "${model}";
            };
          };
        };
      };
    };

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
