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
          Enable machine learning tooling with lsp-ai (local Ollama and GitHub Copilot).
        '';
        type = types.bool;
      };
      model = mkOption {
        default = "llama3:8b";
        description = ''
          Default Ollama model to use for llama chat.
        '';
        type = types.str;
      };
      local = mkOption {
        default = false;
        description = ''
          Prefer local vs cloud ai.
        '';
        type = types.bool;
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
                  model = if cfg.local then "ollama" else "copilot";
                  parameters = if cfg.local then {
                    max_context = 4096;
                    max_tokens = 1024;
                    system = "You are a code assistant chatbot. The user will ask you for assistance coding and you will do you best to answer succinctly and accurately";
                    options = {
                      num_predict = 32;
                    };
                  } else {
                    max_token = 500;
                    max_context = 2048;
                    messages = [
                      {
                        role = "system";
                        content = ''
                          Instructions:
                          - You are an AI programming assistant.
                          - Given a piece of code with the cursor location marked by "<CURSOR>", replace "<CURSOR>" with the correct code or comment.
                          - First, think step-by-step.
                          - Describe your plan for what to build in pseudocode, written out in great detail.
                          - Then output the code replacing the "<CURSOR>"
                          - Ensure that your completion fits within the language context of the provided code snippet (e.g., Python, JavaScript, Rust).
                          Rules:
                          - Only respond with code or comments.
                          - Only replace "<CURSOR>"; do not include any previously written code.
                          - Never include "<CURSOR>" in your response
                          - If the cursor is within a comment, complete the comment meaningfully.
                          - Handle ambiguous cases by providing the most contextually appropriate completion.
                          - Be consistent with your responses.
                        '';
                      }
                      {
                        role = "user";
                        content = ''
                          def greet(name):
                              print(f"Hello, {<CURSOR>}")
                        '';
                      }
                      {
                        role = "assistant";
                        content = "name";
                      }
                      {
                        role = "user";
                        content = ''
                          function sum(a, b) {
                              return a + <CURSOR>;
                          }
                        '';
                      }
                      {
                        role = "assistant";
                        content = "b";
                      }
                      {
                        role = "user";
                        content = ''
                          fn multiply(a: i32, b: i32) -> i32 {
                              a * <CURSOR>
                          }
                        '';
                      }
                      {
                        role = "assistant";
                        content = "b";
                      }
                      {
                        role = "user";
                        content = ''
                          # <CURSOR>
                          def add(a, b):
                              return a + b
                        '';
                      }
                      {
                        role = "assistant";
                        content = "Adds two numbers";
                      }
                      {
                        role = "user";
                        content = ''
                          # This function checks if a number is even
                          <CURSOR>
                        '';
                      }
                      {
                        role = "assistant";
                        content = ''
                          def is_even(n):
                              return n % 2 == 0
                        '';
                      }
                      {
                        role = "user";
                        content = "{CODE}";
                      }
                    ];
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
                copilot = {
                  type = "open_ai";
                  chat_endpoint = "https://api.githubcopilot.com/chat/completions";
                  model = "";
                  auth_token_env_var_name = "GITHUB_TOKEN";
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
