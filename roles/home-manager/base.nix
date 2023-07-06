{ config, pkgs, home-manager, nur, ... }:

{
  home.stateVersion = "23.05";
  home.enableNixpkgsReleaseCheck = false;
  nix = {
    package = pkgs.nix;
    extraOptions = ''
      experimental-features = nix-command flakes
    '';
  };

  # Packages I need installed on every system
  home.packages = with pkgs; [
    _1password
    aerc
    ansible
    ansible-lint
    bind
    bitwarden-cli
    #coder #Marked broken
    coreutils
    curl
    dante
    docker-client
    docker-compose
    doctl
    dos2unix
    file
    findutils
    fzf
    gcc
    git
    git-lfs
    github-cli
    gitleaks
    glow
    gnupg
    gnumake
    gnused
    gomuks
    gotify-cli
    htop
    inetutils
    jq
    kind
    k9s
    kubectl
    kubernetes-helm
    lefthook
    libarchive
    libvirt
    lima
    linode-cli
    mosh
    nim
    nixfmt
    nmap
    nodePackages.cspell
    openssl
    operator-sdk
    pandoc
    pciutils
    pomerium-cli
    popeye
    pwgen
    python3Packages.bandit
    python3
    rbw
    screen
    tcpdump
    tmux
    tor
    torsocks
    tree
    unzip
    vultr-cli
    w3m
    yamllint
    zip
  ];

  # Import nur as nixpkgs.overlays
  nixpkgs.overlays = [
    nur.overlay
  ];

  programs.git = {
    enable = true;
    extraConfig = {
      user = {
          email = "l.spencer.heywood@protonmail.com";
          name = "Spencer Heywood";
      };
      core = {
          editor = "vim";
          autocrlf = "input";
          whitespace = "cr-at-eol";
          pager = "less -+F";
      };
      mergetool = {
          prompt = "true";
      };
      merge = {
          tool = "vimdiff";
          conflictstyle = "diff3";
      };
      color = {
          ui = "auto";
      };
      diff = {
          renames = "copies";
      };
      push = {
          default = "simple";
      };
      format = {
          pretty = "%Cred%h%Creset -%C(yellow)%d%Creset %s %Cgreen(%cd) %C(bold blue)<%an>%Creset";
      };
      pull = {
          ff = "only";
      };
    };
  };

  programs.password-store = {
    enable = true;
    package = pkgs.pass.withExtensions (exts: [ exts.pass-otp ]);
  };

  # Enable Starship (disabled in non-GUI builds)
  programs.starship = {
    enable = true;
    enableZshIntegration = true;
    settings = {
      character = {
        success_symbol = "[❯](bold white)";
      };
    };
  };

  programs.tmux = {
    enable = true;
    clock24 = true;
    extraConfig = ''
      # Change default prefix key to C-a, similar to screen
      unbind-key C-b
      set-option -g prefix C-a

      # Enable 24-bit color support
      set-option -ga terminal-overrides ",xterm-termite:Tc"

      # Start window indexing at one
      set-option -g base-index 1

      # Use vi-style key bindings in the status line, and copy/choice modes
      set-option -g status-keys vi
      set-window-option -g mode-keys vi

      # Large scrollback history
      set-option -g history-limit 10000

      # Xterm Keys on
      set-window-option -g xterm-keys on

      # Set 256 colors
      set -g default-terminal "screen-256color"

      # Set escape time to zero
      set -sg escape-time 0

      # move between panes with vim-like motions
      bind h select-pane -L
      bind j select-pane -D
      bind k select-pane -U
      bind l select-pane -R

      unbind % # Split vertically
      unbind '"' # Split horizontally

      bind-key | split-window -h -c "#{pane_current_path}"
      bind-key - split-window -v -c "#{pane_current_path}"

      # Synchronizing panes
      #bind-key y set-window-option synchronize-panes

      # SSH to Host
      bind-key S command-prompt -p ssh: "new-window -n %1 'ssh %1'"
      # Mosh to Host
      bind-key M command-prompt -p mosh: "new-window -n %1 'mosh %1'"

      # Mouse mode
      set -g mouse on

      # Tmux Scrolling
      bind -n WheelUpPane   select-pane -t= \; copy-mode -e \; send-keys -M
      bind -n WheelDownPane select-pane -t= \;                 send-keys -M

      bind a send-prefix

      # vim-selection
      bind-key -T copy-mode-vi 'v' send-keys -X begin-selection

      # Status bar
      set -g status off
      #set -g status-left "#[fg=black,bg=blue,bold] #S #[fg=blue,bg=black,nobold,noitalics,nounderscore]"
      #set -g status-right "#{prefix_highlight}#[fg=brightblack,bg=black,nobold,noitalics,nounderscore]#[fg=white,bg=brightblack] %Y-%m-%d #[fg=white,bg=brightblack,nobold,noitalics,nounderscore]#[fg=white,bg=brightblack] %H:%M #[fg=cyan,bg=brightblack,nobold,noitalics,nounderscore]#[fg=black,bg=cyan,bold] #H "
    '';
    plugins = with pkgs.tmuxPlugins; [
      nord
      yank
    ];
  };

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
      config.font_size = 14.0

      -- Appearance tweaks
      config.window_decorations = "NONE"
      config.hide_tab_bar_if_only_one_tab = true
      config.audible_bell = "Disabled"

      -- Set zsh to default shell
      config.default_prog = { '/home/heywoodlh/.nix-profile/bin/zsh' }

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



  programs.zsh = {
    enable = true;
    enableCompletion = true;
    enableAutosuggestions = true;
    enableSyntaxHighlighting = true;

    # Set variables here because Darwin has a bug with zshenv https://github.com/nix-community/home-manager/issues/1782#issuecomment-777500002
    initExtra = ''
      export EDITOR="vim"
      export PAGER="less"
      export PATH="$HOME/.nix-profile/bin:/etc/profiles/per-user/heywoodlh/bin:/run/current-system/sw/bin:$PATH"

      [[ -e ~/.ssh ]] || mkdir -p -m 700 ~/.ssh

      [[ -e ~/.zsh.d/functions ]] && source ~/.zsh.d/functions
      [[ -e ~/.zsh.d/docker ]] && source ~/.zsh.d/docker
      [[ -e ~/.zsh.d/custom ]] && source ~/.zsh.d/custom

      # Set ssh-unlock if it's not already set
      alias op-unlock='eval $(op signin)'
      alias | grep -q ssh-unlock || alias ssh-unlock="op read 'op://Personal/id_rsa/private key' | ssh-add -t 4h -"

      # coder-unlock
      alias coder-unlock='eval $(op signin) && export CODER_SESSION_TOKEN=$(op read "op://Personal/6z7y5hf7uroa3fkkm3eu6qkfse/password") && export CODER_URL="https://coder.heywoodlh.io"'

      # Set bw-unlock alias
      alias bw-unlock='export BW_SESSION="$(bw unlock --raw)"'

      # Set culug-do-unlock alias
      alias culug-do-unlock='export DIGITALOCEAN_ACCESS_TOKEN="$(bw get password d7952a46-bc1a-4c32-b038-b0050177111d)"'

      # Set vultr-unlock alias
      alias vultr-unlock='export VULTR_API_KEY="$(bw get password 2eb34e09-f5b4-4fc2-9c65-ace7013dd1b4)"'
    '';

    # Enable oh-my-zsh
    oh-my-zsh = {
      enable = true;
      plugins = [
        "1password"
        "aliases"
        "ansible"
        "aws"
        "battery"
        "brew"
        "docker"
        "git"
        "helm"
        "kubectl"
        "nmap"
        "pass"
        "python"
        "ssh-agent"
      ];
    };
  };
  home.file.".zsh.d/functions" = {
    text = import ./zsh.d/functions.nix;
  };
  home.file.".zsh.d/docker" = {
    text = import ./zsh.d/docker.nix;
  };

  home.file."tmp/.placeholder.txt" = {
    text = "";
  };

  home.file."share/redirector.json" = {
    text = import ./share/redirector.json.nix;
  };
}
