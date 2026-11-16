{ config, lib, options, ... }:

with lib;

let
  cfg = config.heywoodlh.nix-llama;
  username = config.heywoodlh.defaults.user.name;
in {
  options.heywoodlh.nix-llama = {
    enable = mkOption {
      default = false;
      description = ''
        Enable nix-llama, a self-hosted llama.cpp server.
      '';
      type = types.bool;
    };
    host = mkOption {
      default = "127.0.0.1";
      description = ''
        Address nix-llama listens on.
      '';
      type = types.str;
    };
    port = mkOption {
      default = 8080;
      description = ''
        Port nix-llama listens on.
      '';
      type = types.port;
    };
    acceleration = mkOption {
      default = "auto";
      description = ''
        llama.cpp backend. `auto` infers it from the system configuration.
      '';
      type = types.enum [ "auto" "none" "cuda" "rocm" "vulkan" "metal" ];
    };
    contextSize = mkOption {
      default = null;
      description = ''
        Context window in tokens. `null` lets nix-llama size it (capped at 32768).
      '';
      type = types.nullOr types.ints.positive;
    };
    extraConf = mkOption {
      default = {};
      description = ''
        Extra configuration of `services.nix-llama`.
      '';
      type = types.attrs;
    };
    opencode = {
      enable = mkOption {
        default = true;
        description = ''
          Add the local nix-llama instance as an OpenCode provider.
        '';
        type = types.bool;
      };
      name = mkOption {
        default = "nix-llama-local";
        description = ''
          Provider name in OpenCode.
        '';
        type = types.str;
      };
      outputTokens = mkOption {
        default = 8192;
        description = ''
          Value for `limit.output` of the model in OpenCode.
        '';
        type = types.ints.positive;
      };
    };
  };

  config = mkIf cfg.enable (mkMerge [
    {
      assertions = [
        {
          assertion = options ? services.nix-llama;
          message = "heywoodlh.nix-llama requires nix-llama's nixosModules.default or darwinModules.default.";
        }
      ];
    }
    # Exported module sets may be used without nix-llama's module
    (optionalAttrs (options ? services.nix-llama) {
      services.nix-llama = mkMerge [
        {
          enable = true;
          inherit (cfg) host port acceleration;
          tuning.contextSize = cfg.contextSize;
        }
        cfg.extraConf
      ];

      home-manager.users.${username}.programs.opencode.settings.provider.${cfg.opencode.name} = mkIf cfg.opencode.enable {
        npm = "@ai-sdk/openai-compatible";
        name = cfg.opencode.name;
        options.baseURL = "http://127.0.0.1:${toString cfg.port}/v1";
        models.nix-llama = {
          name = "nix-llama";
          tool_call = true;
          limit = {
            context = if cfg.contextSize != null then cfg.contextSize else 32768;
            output = cfg.opencode.outputTokens;
          };
        };
      };
    })
  ]);
}
