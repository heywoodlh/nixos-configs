{
  description = "heywoodlh vscode config";

  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
  inputs.flake-utils.url = "github:numtide/flake-utils";
  inputs.nix-vscode-extensions.url = "github:nix-community/nix-vscode-extensions";
  inputs.fish-flake = {
    url = ../fish;
    inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = inputs@{
    self,
    nixpkgs,
    flake-utils,
    fish-flake,
    nix-vscode-extensions,
  }:
  flake-utils.lib.eachDefaultSystem (system: let
      pkgs = import nixpkgs {
        inherit system;
        config.allowUnfree = true;
      };
      allExtensions = nix-vscode-extensions.extensions.${system};
      myVSCode = (pkgs.vscode-with-extensions.override {
        vscodeExtensions = with allExtensions.vscode-marketplace; [
          arcticicestudio.nord-visual-studio-code
          coder.coder-remote
          continue.continue
          eamodio.gitlens
          github.codespaces
          github.copilot
          jnoortheen.nix-ide
          mkhl.direnv
          ms-azuretools.vscode-docker
          ms-kubernetes-tools.vscode-kubernetes-tools
          ms-python.python
          pkgs.vscode-extensions.ms-vscode-remote.remote-containers
          pkgs.vscode-extensions.ms-vscode-remote.remote-ssh
          shardulm94.trailing-spaces
          tailscale.vscode-tailscale
          timonwong.shellcheck
          vscodevim.vim
        ];
      });

      myFish = fish-flake.packages.${system}.fish;
      fishProfile = {
        "fish" = {
          "path" = "${myFish}/bin/fish";
        };
      };
      vscode-keybindings = pkgs.writeText "keybindings.json" (builtins.toJSON [
        {
          key = "ctrl+t";
          command = "workbench.action.terminal.toggleTerminal";
        }
        {
          key = "ctrl+w h";
          command = "workbench.action.focusLeftGroup";
        }
        {
          key = "ctrl+w l";
          command = "workbench.action.focusRightGroup";
        }
        {
          key = "ctrl+w j";
          command = "workbench.action.focusBelowGroup";
        }
        {
          key = "ctrl+w k";
          command = "workbench.action.focusAboveGroup";
        }
        {
          key = "ctrl+w s";
          command = "workbench.action.splitEditorDown";
        }
        {
          key = "ctrl+w v";
          command = "workbench.action.splitEditorRight";
        }
        {
          key = "g a";
          command = "git.stage";
          when = "vim.mode == 'Normal' && !terminalFocus";
        }
        {
          key = "ctrl+w w";
          command = "workbench.action.focusNextPart";
        }
        {
          key = "ctrl+n";
          command = "workbench.action.toggleSidebarVisibility";
        }
        {
          key = "ctrl+a shift+\\";
          command = "workbench.action.terminal.split";
          when = "terminalFocus";
        }
      ]);

      vscode-settings = pkgs.writeText "settings.json" (builtins.toJSON {
        # Privacy/telemetry settings
        "Lua.telemetry.enable" = false;
        "clangd.checkUpdates" = false;
        "code-runner.enableAppInsights" = false;
        "docker-explorer.enableTelemetry" = false;
        "editor.fontFamily" = "'JetBrainsMono Nerd Font Mono', 'monospace', 'Droid Sans Mono', 'monospace', 'Droid Sans Fallback'";
        "extensions.ignoreRecommendations" = true;
        "gitlens.showWelcomeOnInstall" = false;
        "gitlens.showWhatsNewAfterUpgrades" = false;
        "java.help.firstView" = "none";
        "java.help.showReleaseNotes" = false;
        "julia.enableTelemetry" = false;
        "kite.showWelcomeNotificationOnStartup" = false;
        "liveServer.settings.donotShowInfoMsg" = true;
        "material-icon-theme.showWelcomeMessage" = false;
        "pros.showWelcomeOnStartup" = false;
        "pros.useGoogleAnalytics" = false;
        "redhat.telemetry.enabled" = false;
        "remote.SSH.useLocalServer" = false;
        "rpcServer.showStartupMessage" = false;
        "shellcheck.disableVersionCheck" = true;
        "sonarlint.disableTelemetry" = true;
        "telemetry.enableCrashReporter" = false;
        "telemetry.enableTelemetry" = false;
        "telemetry.telemetryLevel" = "off";
        "terraform.telemetry.enabled" = false;
        "update.showReleaseNotes" = false;
        "vsicons.dontShowNewVersionMessage" = true;
        "workbench.welcomePage.walkthroughs.openOnInstall" = false;
        # Appearance settings
        "editor.minimap.enabled" = false;
        "update.mode" = "none";
        "workbench.activityBar.location" = "bottom";
        "workbench.colorTheme" = "Nord";
        "workbench.remoteIndicator.showExtensionRecommendations" = false;
        "workbench.startupEditor" = false;
        "editor.fontSize" = 16;
        "terminal.integrated.fontSize" = 16;
        #"workbench.statusBar.visible" = false;
        "workbench.tips.enabled" = false;
        "workbench.tree.indent" = 4;
        # Terminal settings
        "terminal.integrated.macOptionIsMeta" = true;
        "terminal.integrated.shellIntegration.enabled" = true;
        "terminal.integrated.profiles.linux" = fishProfile;
        "terminal.integrated.profiles.osx" = fishProfile;
        "terminal.integrated.defaultProfile.linux" = "fish";
        "terminal.integrated.defaultProfile.osx" = "fish";
        # Vim settings
        "vim.shell" = "${pkgs.bash}/bin/bash";
        "vim.useSystemClipboard" = true;
        # Nix settings
        "nix.enableLanguageServer" = true;
        "nix.serverPath" = "${pkgs.nixd}/bin/nixd";
        # Misc settings
        "git.openRepositoryInParentFolders" = "always";
        "security.workspace.trust.enabled" = true; # Required for direnv
        "direnv.path.executable" = "${pkgs.direnv}/bin/direnv";
        "trailing-spaces.includeEmptyLines" = true;
        "trailing-spaces.highlightCurrentLine" = false;
        "trailing-spaces.deleteModifiedLinesOnly" = true;
        "trailing-spaces.trimOnSave" = true;
      });

      userDir = pkgs.stdenv.mkDerivation {
        name = "userDir";
        builder = pkgs.bash;
        args = [ "-c" "${pkgs.coreutils}/bin/mkdir -p $out; ${pkgs.coreutils}/bin/cp ${vscode-settings} $out/settings.json; ${pkgs.coreutils}/bin/cp ${vscode-keybindings} $out/keybindings.json" ];
      };
      heywoodlh-vscode = pkgs.writeShellScriptBin "code" ''
        dataDir="$HOME/Documents/heywoodlh-code"
        mkdir -p "$dataDir/User"
        rm "$dataDir/User/settings.json" &>/dev/null || true
        rm "$dataDir/User/keybindings.json" &>/dev/null || true
        ln -s ${userDir}/settings.json "$dataDir/User/settings.json"
        ln -s ${userDir}/keybindings.json "$dataDir/User/keybindings.json"
        ${myVSCode}/bin/code --user-data-dir "$dataDir" $@
      '';
    in {
      packages = {
        user-dir = userDir;
        code-bin = myVSCode;
        default = heywoodlh-vscode;
      };
    });
}
