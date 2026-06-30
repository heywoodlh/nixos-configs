{ config, pkgs, lib, myFlakes, opencode-ssh, ... }:

with lib;
with lib.types;

let
  cfg = config.heywoodlh.home.llm;
  homeDir = config.home.homeDirectory;
  vllmLogDir = "${homeDir}/.local/share/vllm/logs";
  vllmModelsDir = "${homeDir}/.local/share/vllm/models";
  vllm-metal-src = pkgs.fetchFromGitHub {
    owner = "vllm-project";
    repo = "vllm-metal";
    rev = "0348cd334482dc6b03028b14abd08c92ef32ba8f";
    hash = "sha256-ro1ne9kLGdQtGcp06CG9yJE3dV2Y1bSRzLfoasSRQtU=";
  };
  vllmPkg = pkgs.writeShellScriptBin "vllm" (if pkgs.stdenv.isDarwin then ''
    VENV="$HOME/.venv-vllm-metal"
    if [ ! -f "$VENV/bin/vllm" ]; then
      INSTALL_TMP=$(mktemp)
      cp ${vllm-metal-src}/install.sh "$INSTALL_TMP"
      bash "$INSTALL_TMP"
      rm -f "$INSTALL_TMP"
    fi
    exec "$VENV/bin/vllm" "$@"
  '' else ''
    ${pkgs.pipx}/bin/pipx run vllm $@
  '');
  runVllm = pkgs.writeShellScript "vllm.sh" ''
    ${vllmPkg}/bin/vllm serve "${cfg.opencode.vllm.model.name}" --download-dir "${vllmModelsDir}" --port ${toString cfg.opencode.vllm.port} ${cfg.opencode.vllm.extraArgs}
  '';
  opencodeType = submodule {
    options = {
      enable = mkOption {
        default = true;
        description = ''
          Configure OpenCode.
        '';
        type = bool;
      };
      ssh = mkOption {
        default = true;
        description = ''
          Enable opencode-ssh.
        '';
        type = bool;
      };
      vllm = let
        vllmType = submodule {
          options = {
            enable = mkOption {
              default = false;
              description = ''
                Enable local vllm for OpenCode (named `vllm-local` by default).
              '';
              type = bool;
            };
            name = mkOption {
              default = "vllm-local";
              description = ''
                Provider name in OpenCode.
              '';
              type = str;
            };
            port = mkOption {
              default = 11435;
              description = ''
                Port to run vllm on.
              '';
              type = int;
            };
            extraArgs = lib.mkOption {
              type = str;
              default = "--max-model-len 8192 --max-num-batched-tokens 8192 --gpu-memory-utilization 0.50 --tool-call-parser openai --enable-auto-tool-choice";
              description = ''
                CLI flags after `vllm serve MODEL --host … --port …`.
              '';
            };
            model = let
              modelType = submodule {
                options = {
                  name = mkOption {
                    default = "Qwen/Qwen2.5-Coder-3B-Instruct";
                    description = ''
                      Name of Model on HuggingFace for vllm.
                      Found at "Use this model" > "vLLM".
                    '';
                    type = str;
                  };
                  alias = mkOption {
                    default = "qwen-coder";
                    description = ''
                      Human-readable name for model in OpenCode.
                    '';
                    type = str;
                  };
                  outputTokens = mkOption {
                    default = 2048;
                    description = ''
                      Value for `limit.output` of model in OpenCode configuration.
                      Should not exceed the vllm --max-model-len value.
                    '';
                    type = int;
                  };
                  contextTokens = mkOption {
                    default = 6144;
                    description = ''
                      Value for `limit.context` of model in OpenCode configuration.
                    '';
                    type = int;
                  };
                };
              };
            in mkOption {
              default = {};
              description = "Local model to pull in vllm.";
              type = modelType;
            };
          };
        };
      in mkOption {
        default = {};
        description = "Enable local vllm + OpenCode.";
        type = vllmType;
      };
      extraConf = mkOption {
        default = {};
        description = ''
          Extra configuration of `programs.opencode.settings`.
        '';
        type = attrs;
      };
    };
  };
in {
  options = {
    heywoodlh.home.llm = {
      enable = mkOption {
        default = false;
        description = ''
          Enable heywoodlh llm configuration.
        '';
        type = bool;
      };
      homelab = mkOption {
        default = false;
        description = ''
          This option is only useful to author.
        '';
        type = bool;
      };
      opencode = mkOption {
        default = {};
        description = "Enable local OpenCode configuration.";
        type = opencodeType;
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
  in mkIf cfg.enable {
    home.packages = with pkgs; [
      github-copilot-cli
      claude-code
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

    home.file.".config/opencode/plugins/remote.ts" = {
      enable = (cfg.opencode.enable && cfg.opencode.ssh);
      text = builtins.readFile "${opencode-ssh}/src/index.ts";
    };

    home.file.".opencode/agent/remote.md" = {
      enable = (cfg.opencode.enable && cfg.opencode.ssh);
      text = ''
        ---
        description: Run commands on a remote server via SSH
        color: primary
        mode: primary
        ---
        When the user says "ssh <host>", use `ssh_connect` with the host name.
        When they say "local", use `ssh_disconnect`.
      '';
    };

    launchd.agents.vllm = {
      enable = cfg.opencode.vllm.enable;
      config = {
        ProgramArguments = [
          "${runVllm}"
        ];
        RunAtLoad = true;
        KeepAlive = true;
        StandardOutPath = "${vllmLogDir}/stdout.log";
        StandardErrorPath = "${vllmLogDir}/stderr.log";
      };
    };

    systemd.user.services.vllm = {
      enable = cfg.opencode.vllm.enable;
      Unit = {
        Description = "vllm server";
        After = [ "network.target" ];
      };

      Service = {
        Type = "idle";
        KillSignal = "SIGINT";
        ExecStart = "${runVllm}";
        Restart = "always";
        RestartSec = 300;
      };
    };

    programs.opencode = optionalAttrs (cfg.opencode.enable) {
      enable = cfg.opencode.enable;
      settings = {
        provider.vllm = optionalAttrs (cfg.opencode.enable && cfg.opencode.vllm.enable) {
          npm = "@ai-sdk/openai-compatible";
          name = "${cfg.opencode.vllm.name}";
          options.baseURL = "http://localhost:${toString cfg.opencode.vllm.port}/v1";
          models = {
            "${cfg.opencode.vllm.model.name}" = {
              name = "${cfg.opencode.vllm.model.alias}";
              tool_call = true;
              options.think = false;
              limit = {
                context = cfg.opencode.vllm.model.contextTokens;
                output = cfg.opencode.vllm.model.outputTokens;
              };
            };
          };
        };
      } // optionalAttrs (cfg.opencode.enable) cfg.opencode.extraConf;
    };
  };
}
