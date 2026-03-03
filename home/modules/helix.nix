{ config, lib, pkgs, myFlakes, ... }:

with lib;

let
  cfg = config.heywoodlh.home.helix;
  system = pkgs.stdenv.hostPlatform.system;
  myHelix = myFlakes.packages.${system}.helix;
  myFish = myFlakes.packages.${system}.fish;
in {
  options = {
    heywoodlh.home.helix = {
      enable = mkOption {
        default = false;
        description = ''
          Enable heywoodlh helix configuration.
        '';
        type = types.bool;
      };
      homelab = mkOption {
        default = false;
        description = ''
          Enable heywoodlh homelab-dependent configuration.
          Will only be useful to author.
        '';
        type = types.bool;
      };
      ai = mkOption {
        default = true;
        description = ''
          Enable machine learning tooling with lsp-ai.
        '';
        type = types.bool;
      };
      model = mkOption {
        default = "llama3:8b";
        description = ''
          Default Ollama model to use for chat.
        '';
        type = types.str;
      };
    };
  };

  config = mkIf cfg.enable {
    home.packages = let
      chat = pkgs.writeShellScriptBin "chat" ''
        if [[ ! -e "$HOME/.lsp-ai.md" ]]
        then
          printf "[comment]: <> (Start a new prompt after "!C", then Space+a to begin conversation)\n" > "$HOME/.lsp-ai.md"
        fi

        ${myHelix}/bin/hx + $HOME/.lsp-ai.md
      '';
    in with pkgs; optionals (cfg.ai) [
      chat
      lsp-ai
    ];
    programs.helix = {
      enable = true;
      package = myHelix;
      defaultEditor = true;
      extraPackages = with pkgs; [
        bash-language-server
        fish-lsp
        gopls
        harper
        marksman
        nil
        ty
      ] ++ optionals (cfg.ai) [
        lsp-ai
      ];
      settings = {
        theme = "custom";
        editor = {
          shell = [
            "${myFish}/bin/fish"
            "-c"
          ];
          auto-pairs = false;
          cursor-shape = {
            insert = "bar";
            normal = "block";
          };
          whitespace = {
            render = {
              space = "trailing";
              tab = "trailing";
              nbsp = "trailing";
              nnbsp = "trailing";
            };
            characters = {
              space = "·";
              tab = "┆";
            };
          };
          lsp.display-inlay-hints = true;
          soft-wrap.enable = true;
          inline-diagnostics = {
            cursor-line = "hint";
            other-lines = "error";
          };
        };
        keys = {
          normal.space = {
            i = ":toggle lsp.display-inlay-hints";
          };
        };
      };
      languages = {
        language-server = {
          harper = {
            command = "harper-ls";
            args = [ "--stdio" ];

            config.harper-ls = {
              diagnosticSeverity = "hint";
              dialect = "American";
              linters = { long_sentences = false; };
            };
          };
          "lsp-ai" = optionalAttrs (cfg.ai) {
            command = "lsp-ai";
            args = ["--use-seperate-log-file"];
            config = {
              memory.file_store = { };
              chat = [
                {
                  trigger = "!C";
                  action_display_name = "chat";
                  model = "ollama";
                  parameters = {
                    max_context = 4096;
                    max_tokens = 1024;
                    system = "You are a code assistant chatbot. The user will ask you for assistance coding and you will do you best to answer succinctly and accurately";
                  };
                }
              ];
              models = {
                ollama = let
                  url = if cfg.homelab then "http://ollama.barn-banana.ts.net:11434" else "http://127.0.0.1:11434";
                in {
                  type = "ollama";
                  model = "${cfg.model}";
                  chat_endpoint = "${url}/api/chat";
                  generate_endpoint = "${url}/api/generate";
                };
              };
            };
          };
        };
        language = [
          {
            name = "markdown";
            language-servers = [
              "marksman"
              "harper"
            ] ++ lib.optionals (cfg.ai) [
              "lsp-ai"
            ];
          }
        ];
      };
      # My overrides to base16_transparent theme
      themes.custom = {
        inherits = "base16_transparent";
        "comment".fg = "comment";
        "diagnostic.hint".underline = {
          color = "#5E81AC";
          style = "curl";
        };
        "hint" = "#5E81AC";
        "ui.virtual.inlay-hint" = {
          fg = "#4C566A";
          modifiers = ["italic"];
        };
      };
    };

    nix.settings = {
      extra-substituters = [
        "https://heywoodlh-helix.cachix.org"
      ];
      extra-trusted-public-keys = [
        "heywoodlh-helix.cachix.org-1:qHDV95nI/wX9pidAukzMzgeok1415rgjMAXinDsbb7M="
      ];
    };
  };
}
