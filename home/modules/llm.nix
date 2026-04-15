{ config, pkgs, lib, myFlakes, ... }:

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
      homelab = mkOption {
        default = false;
        description = ''
          This option is only useful to author.
        '';
        type = types.bool;
      };
    };
  };
  config = let
    url = "http://localhost:11434";
    system = pkgs.stdenv.hostPlatform.system;
    op-wrapper = "${myFlakes.packages.${system}.op-wrapper}/bin/op-wrapper";
    # Lightweight model to always pull
    model = "llama3.1:8b";
    myCodexLitellm = pkgs.writeShellScriptBin "codex-litellm" ''
      LLM_API_KEY="$(${op-wrapper} item get zvj57fg53iipc4vxgobcer5j4q --fields master-key --reveal)"
      ${pkgs.codex}/bin/codex --profile "qwen" $@
    '';
    ollamaPkg = if (cfg.homelab == false) then config.services.ollama.package else pkgs.ollama;
    myOllamaPull = pkgs.writeShellScript "ollama-pull" ''
      # Loop 3 times until model is pulled
      (r=3;while ! ${ollamaPkg}/bin/ollama list &>/dev/null ; do ((--r))||exit;sleep 60;done) && ${ollamaPkg}/bin/ollama pull ${model}
    '';
  in mkIf cfg.enable {
    home.packages = with pkgs; [
      github-copilot-cli
      claude-code
      ollamaPkg
    ] ++ lib.optionals (cfg.homelab) [
      myCodexLitellm
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
        } // lib.optionalAttrs (cfg.homelab == true) {
          js_repl = false;
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
      } // lib.optionalAttrs (cfg.homelab) {
        model_provider = "llama";
        model_providers = {
          llama = {
            name = "llama";
            baseURL = "http://llama-swap.barn-banana.ts.net/v1";
            envKey = "LLM_API_KEY";
            wire_api = "responses";
            stream_idle_timeout_ms = 10000000;
          };
        };
        profiles.qwen = {
          model = "qwen3.5:9b";
          model_provider = "llama";
          web_search = "disabled";
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

    systemd.user.services.ollama-pull = lib.optionalAttrs (cfg.homelab == false) {
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

    launchd.agents.ollama-pull = lib.optionalAttrs (cfg.homelab == false) {
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
