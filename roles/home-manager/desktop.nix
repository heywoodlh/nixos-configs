{ config, pkgs, home-manager, nur, ... }:

{
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

  programs.wezterm = {
    enable = true;
    extraConfig = ''
      -- Pull in the wezterm API
      local wezterm = require 'wezterm'

      -- This table will hold the configuration.
      local config = {}

      -- In newer versions of wezterm, use the config_builder which will
      -- help provide clearer error messages
      if wezterm.config_builder then
        config = wezterm.config_builder()
      end

      -- This is where you actually apply your config choices

      -- Nord color scheme:
      config.color_scheme = 'nord'
      config.font = wezterm.font 'JetBrainsMono Nerd Font Mono'
      config.font_size = 16.0

      -- Appearance tweaks
      config.window_decorations = "RESIZE"
      config.hide_tab_bar_if_only_one_tab = true
      config.audible_bell = "Disabled"

      -- Set zsh to default shell
      config.default_prog = { "${pkgs.zsh}/bin/zsh" }

      -- Disable hiding mouse cursor when typing
      -- Assumes something else will hide cursor
      -- (i.e. Cursorcerer on MacOS, unclutter on Linux)
      config.hide_mouse_cursor_when_typing = false

      -- Keybindings
      config.leader = { key = 'a', mods = 'CTRL', timeout_milliseconds = 1000 }
      config.keys = {
        {
          key = '|',
          mods = 'LEADER|SHIFT',
          action = wezterm.action.SplitHorizontal { domain = 'CurrentPaneDomain' },
        },
        {
          key = '-',
          mods = 'LEADER',
          action = wezterm.action.SplitVertical { domain = 'CurrentPaneDomain' },
        },
        {
          key = 'h',
          mods = 'LEADER',
          action = wezterm.action.ActivatePaneDirection 'Left',
        },
        {
          key = 'j',
          mods = 'LEADER',
          action = wezterm.action.ActivatePaneDirection 'Down',
        },
        {
          key = 'k',
          mods = 'LEADER',
          action = wezterm.action.ActivatePaneDirection 'Up',
        },
        {
          key = 'l',
          mods = 'LEADER',
          action = wezterm.action.ActivatePaneDirection 'Right',
        },
        {
          key = "[",
          mods = "LEADER",
          action = wezterm.action.ActivateCopyMode,
        },
      }

      -- and finally, return the configuration to wezterm
      return config
    '';
  };
}
