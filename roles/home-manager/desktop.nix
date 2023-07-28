{ config, pkgs, home-manager, nur, ... }:

let
  system = pkgs.system;
in {
  home.packages = [
    pkgs.mdp
  ];

  programs.vscode = {
    enable = true;
    enableExtensionUpdateCheck = false;
    enableUpdateCheck = false;
    extensions = with pkgs.vscode-extensions; [
      arcticicestudio.nord-visual-studio-code
      eamodio.gitlens
      github.copilot
      jnoortheen.nix-ide
      ms-python.python
      vscodevim.vim
    ];
    keybindings = [
      {
        key = "ctrl+t";
        command = "workbench.action.terminal.toggleTerminal";
      }
      {
        key = "ctrl+n";
        command = "workbench.action.toggleSidebarVisibility";
      }
    ];
    userSettings = {
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
      "terminal.integrated.macOptionIsMeta" = true;
      "terminal.integrated.shellIntegration.enabled" = true;
      "terraform.telemetry.enabled" = false;
      "update.showReleaseNotes" = false;
      "vim.useSystemClipboard" = true;
      "vsicons.dontShowNewVersionMessage" = true;
      "workbench.colorTheme" = "Nord";
      "workbench.welcomePage.walkthroughs.openOnInstall" = false;
    };
  };
}
