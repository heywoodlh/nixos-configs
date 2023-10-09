{ config, pkgs, home-manager, nur, git-configs, ... }:

let
  homeDir = config.home.homeDirectory;
  aerc-html-filter = pkgs.writeScriptBin "html" ''
    export SOCKS_SERVER="127.0.0.1:1"
    exec ${pkgs.dante}/bin/socksify ${pkgs.w3m}/bin/w3m \
      -T text/html \
      -cols $(${pkgs.ncurses}/bin/tput cols) \
      -dump \
      -o display_image=false \
      -o display_link_number=true
  '';
in {
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
    bind
    coreutils
    curl
    docker-compose
    dos2unix
    file
    findutils
    fzf
    gcc
    git-lfs
    github-cli
    gitleaks
    glow
    gnupg
    gnumake
    gnused
    gomuks
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
    mosh
    nmap
    openssl
    pciutils
    proxychains-ng
    pwgen
    python3
    rbw
    screen
    tcpdump
    tmux
    tor
    torsocks
    tree
    unzip
    zip
  ];

  # Import nur as nixpkgs.overlays
  nixpkgs.overlays = [
    nur.overlay
  ];

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

  # 1Password CLI wrapper
  home.file."bin/op-wrapper.sh" = {
    executable = true;
    text = ''
      #!/usr/bin/env bash
      [[ -z "$OP_SESSION" ]] && eval $(op signin) && export OP_SESSION
      ${pkgs._1password}/bin/op "$@"
    '';
  };

  # 1Password CLI wrapper
  home.file."bin/proxychains" = {
    executable = true;
    text = ''
      #!/usr/bin/env bash
      ${pkgs.proxychains-ng}/bin/proxychains4 "$@"
    '';
  };

  # Proxychains configs
  home.file.".proxychains/proxychains.conf" = {
    enable = true;
    text = ''
      strict_chain
      proxy_dns
      quiet_mode
      remote_dns_subnet 224
      tcp_read_time_out 15000
      tcp_connect_time_out 8000
      localnet 127.0.0.0/255.0.0.0
      [ProxyList]
      socks5 100.113.9.57 1080
    '';
  };

  # Cross-platform shell aliases
  home.shellAliases = {
    op = "${homeDir}/bin/op-wrapper.sh";
  };

  # Aerc
  home.file.".config/aerc/accounts.conf" = {
    enable = true;
    text = ''
      [fastmail]
      source = imaps://heywoodlh%40heywoodlh.io@imap.fastmail.com:993
      source-cred-cmd = ${homeDir}/bin/op-wrapper.sh read 'op://Personal/44abj6tnhmrjdhv6potivbc5by/password'
      outgoing = smtps://heywoodlh%40heywoodlh.io@smtp.fastmail.com:465
      outgoing-cred-cmd = ${homeDir}/bin/op-wrapper.sh read 'op://Personal/44abj6tnhmrjdhv6potivbc5by/password'
      default = INBOX
      from = Spencer Heywood <heywoodlh@heywoodlh.io>

      [protonmail]
      source = imap+insecure://l.spencer.heywood%40protonmail.com@nix-ext-net.tailscale:143
      source-cred-cmd = ${homeDir}/bin/op-wrapper.sh read 'op://Personal/erkt5oy644dks54kax57ib2rue/password'
      outgoing = smtp+plain://l.spencer.heywood%40protonmail.com@nix-ext-net.tailscale:25
      outgoing-cred-cmd = ${homeDir}/bin/op-wrapper.sh read 'op://Personal/erkt5oy644dks54kax57ib2rue/password'
      default = INBOX
      from = Spencer Heywood <l.spencer.heywood@protonmail.com>
    '';
  };
  programs.aerc = {
    enable = true;
    extraConfig = {
      general.unsafe-accounts-conf = true;
      filters = {
        "text/html" = "${aerc-html-filter}/bin/html";
      };
    };
  };
}
