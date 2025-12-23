{ config, lib, pkgs, myFlakes, ... }:

with lib;

let
  cfg = config.heywoodlh.home.helix;
  system = pkgs.stdenv.hostPlatform.system;
  myHelix = myFlakes.packages.${system}.helix;
  myFish = myFlakes.packages.${system}.fish;
  opWrapper = myFlakes.packages.${system}.op-wrapper;
  gptPkg = if (cfg.homelab) then
    pkgs.writeShellScriptBin "helix-gpt" ''
      # Initial auth setup
      if [[ ! -s $HOME/.local/copilot.txt ]]
      then
        mkdir -p $HOME/.local
        ${opWrapper}/bin/op-wrapper read 'op://Personal/pym6vduaunymq6cokn35kupxky/helix-gpt-copilot' > $HOME/.local/copilot.txt
        chmod 600 $HOME/.local/copilot.txt
      fi
      [[ -e $HOME/.local/copilot.txt ]] && export COPILOT_API_KEY="$(cat $HOME/.local/copilot.txt)"
      # Fallback to normal 1password wrapper if copilot.txt does not work out
      [[ -z $COPILOT_API_KEY ]] && export COPILOT_API_KEY=$(${opWrapper}/bin/op-wrapper read 'op://Personal/pym6vduaunymq6cokn35kupxky/helix-gpt-copilot')
      ${pkgs.helix-gpt}/bin/helix-gpt $@
    '' else pkgs.helix-gpt;
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
          Enable machine learning tooling, i.e. Copilot, lsp-ai.
        '';
        type = types.bool;
      };
    };
  };

  config = mkIf cfg.enable {
    home.packages = with pkgs; optionals (cfg.ai) [
      gptPkg
      lsp-ai
    ];
    programs.helix = {
      enable = true;
      package = myHelix;
      defaultEditor = true;
      extraPackages = with pkgs; [
        gopls
        marksman
        nil
        ty
      ] ++ optionals (cfg.ai) [
        gptPkg
        lsp-ai
      ];
      settings = {
        theme = "base16_transparent";
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
          lsp = {
            display-inlay-hints = true;
          };
        };
      };
      languages = optionalAttrs (cfg.ai) {
        copilot = {
          command = "${gptPkg}/bin/helix-gpt";
          args = [
            "--handler" "copilot"
          ];
        };
        "lsp-ai" = {
          command = "lsp-ai";
          args = ["--stdio"];
        };
        language = [
          {
            name = "bash";
            language-servers = [ "bash-language-server" "copilot" ];
          }
          {
            name = "go";
            language-servers = [ "gopls" "copilot" ];
          }
          {
            name = "nix";
            language-servers = [ "nil" "copilot" ];
          }
          {
            name = "python";
            language-servers = [ "ty" "copilot" ];
          }
        ];
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
