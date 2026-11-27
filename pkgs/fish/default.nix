{pkgs, ...}: let
  starship_config = pkgs.writeText "starship.toml" ''
    [character]
    success_symbol = '[❯](bold white)'

    [container]
    disabled = true
  '';
  aws_config = pkgs.writeText "aws.fish" ''
    if test -z "$AWS_CONFIG_FILE"
      set -gx AWS_CONFIG_FILE "$HOME/.aws/config"
    end

    function _get_aws_profiles
      if grep -q '\[profile ' "$AWS_CONFIG_FILE"
        set -x aws_profiles "$(${pkgs.gnugrep}/bin/grep '\[profile' $AWS_CONFIG_FILE)"
        set -x aws_profiles "$(echo $aws_profiles | ${pkgs.gnused}/bin/sed 's/\[profile //g' | ${pkgs.gnused}/bin/sed 's/\]//g')"
        echo $aws_profiles
      end
    end

    function asp
      if test -e "$AWS_CONFIG_FILE"
        set -x aws_profiles "$(${pkgs.gnugrep}/bin/grep '\[profile' $AWS_CONFIG_FILE)"
        set -x aws_profiles "$(echo $aws_profiles | ${pkgs.gnused}/bin/sed 's/\[profile //g' | ${pkgs.gnused}/bin/sed 's/\]//g')"
        set -x profile_selection "$argv[1]"
        if test -z "$profile_selection"
          set -x profile_selection "$(echo $aws_profiles | ${pkgs.coreutils}/bin/tr " " "\n" | ${pkgs.fzf}/bin/fzf)"
        end
        test -n "$profile_selection" && echo "$aws_profiles" | ${pkgs.gnugrep}/bin/grep -q "$profile_selection" && set -gx AWS_PROFILE "$profile_selection"
      end
    end

    complete -e asp
    if test -e "$AWS_CONFIG_FILE"
      complete -x -c asp -d "AWS profiles" -n "_get_aws_profiles" -a "$(_get_aws_profiles)"
    end
  '';
  ps =
    if pkgs.stdenv.hostPlatform.isDarwin
    then "/bin/ps"
    else "${pkgs.ps}/bin/ps";
  psFlags =
    if pkgs.stdenv.hostPlatform.isDarwin
    then "-U $USER"
    else "-fjH -u $USER";
  opUnlockerText = ''
    ${pkgs.coreutils}/bin/mkdir -p -m 700 $HOME/.1password
    test -e $HOME/.1password/session.sh && ${pkgs.gnugrep}/bin/grep -iqE "^OP_SESSION" $HOME/.1password/session.sh && export (${pkgs.coreutils}/bin/head -1 $HOME/.1password/session.sh)
    if ${pkgs._1password-cli}/bin/op --account my account get &>/dev/null
        ${pkgs.coreutils}/bin/echo "1Password CLI already unlocked"
        if ! test -e $HOME/.1password/session.sh
           ${pkgs._1password-cli}/bin/op account list &>/dev/null && ${pkgs.coreutils}/bin/env | ${pkgs.gnugrep}/bin/grep -iE "^OP_SESSION" | ${pkgs.coreutils}/bin/head -1 > $HOME/.1password/session.sh
        end
    else
        eval $(${pkgs._1password-cli}/bin/op signin)
        ${pkgs.coreutils}/bin/env | ${pkgs.gnugrep}/bin/grep -iE "^OP_SESSION" | ${pkgs.coreutils}/bin/head -1 > ~/.1password/session.sh && ${pkgs._1password-cli}/bin/op account list &>/dev/null && ${pkgs.coreutils}/bin/echo "1Password CLI unlocked"
    end
    test -e $HOME/.1password/session.sh && ${pkgs.gnugrep}/bin/grep -iqE "^OP_SESSION" $HOME/.1password/session.sh && export (${pkgs.coreutils}/bin/head -1 $HOME/.1password/session.sh)
  '';
  opUnlocker = pkgs.writeText "op-unlock" ''
    ${opUnlockerText}
  '';
  opWrapperText = ''
    ${pkgs.fish}/bin/fish ${opUnlocker} &>/dev/null
    test -e $HOME/.1password/session.sh && ${pkgs.gnugrep}/bin/grep -iqE "^OP_SESSION" $HOME/.1password/session.sh && export (${pkgs.coreutils}/bin/head -1 $HOME/.1password/session.sh)
    ${pkgs._1password-cli}/bin/op $argv
  '';
  opWrapper = let
    unlocker = pkgs.writeText "op-unlock" ''
      #!${pkgs.fish}/bin/fish
      ${opUnlockerText}
    '';
    wrapper = pkgs.writeText "op-wrapper" ''
      #!${pkgs.fish}/bin/fish
      ${opWrapperText}
    '';
  in
    pkgs.stdenv.mkDerivation {
      name = "op-wrapper";
      builder = pkgs.bash;
      args = [
        "-c"
        "${pkgs.coreutils}/bin/mkdir -p $out/bin; ${pkgs.coreutils}/bin/cp ${wrapper} $out/bin/op-wrapper; ${pkgs.coreutils}/bin/cp ${unlocker} $out/bin/op-unlock; ${pkgs.coreutils}/bin/chmod +x $out/bin/op-wrapper $out/bin/op-unlock"
      ];
    };
  fish_config = pkgs.writeText "profile.fish" ''
    if test -e $HOME/.1password/session.sh
        ${pkgs.gnugrep}/bin/grep -iqE '^OP_SESSION' $HOME/.1password/session.sh || rm -f $HOME/.1password/session.sh
    end

    function add-to-path
        if not contains $argv[1] $PATH
            set -gx PATH $argv[1] $PATH
        end
    end

    add-to-path $HOME/.nix-profile/bin
    add-to-path ${pkgs.coreutils}/bin
    add-to-path ${pkgs.ncurses5}/bin

    test -e /nix/var/nix/profiles/default/etc/profile.d/nix.fish && source /nix/var/nix/profiles/default/etc/profile.d/nix.fish || true

    fish_config theme choose Nord
    set fish_greeting ""

    set -gx STARSHIP_CONFIG "${starship_config}"
    ${pkgs.starship}/bin/starship init fish | source

    ${pkgs.direnv}/bin/direnv hook fish | source

    function start-ssh-agent
        if not echo $SSH_AUTH_SOCK | ${pkgs.gnugrep}/bin/grep -q 1password
            if not ${ps} ${psFlags} | ${pkgs.gnugrep}/bin/grep ssh-agent | ${pkgs.gnugrep}/bin/grep -q "$HOME/.ssh/agent.sock" &> /dev/null
                mkdir -p $HOME/.ssh
                rm -f $HOME/.ssh/agent.sock &> /dev/null
                eval (${pkgs.openssh}/bin/ssh-agent -t 4h -c -a "$HOME/.ssh/agent.sock") &> /dev/null || true
            else
                if not test -e $HOME/.ssh/agent.sock
                  ${pkgs.procps}/bin/pkill -9 ssh-agent &> /dev/null || true
                  eval (${pkgs.openssh}/bin/ssh-agent -t 4h -c -a "$HOME/.ssh/agent.sock") &> /dev/null || true
                end
            end
            export SSH_AUTH_SOCK="$HOME/.ssh/agent.sock"
        end
    end

    if test -z $SSH_CONNECTION
        if test -e $HOME/.1password/agent.sock
            set -gx SSH_AUTH_SOCK "$HOME/.1password/agent.sock"
        end
        if test -e "$HOME/Library/Group Containers/2BUA8C4S2C.com.1password/t/agent.sock"
            set -gx SSH_AUTH_SOCK "$HOME/Library/Group Containers/2BUA8C4S2C.com.1password/t/agent.sock"
        end
        start-ssh-agent
    else
        if test -z $SSH_AUTH_SOCK
            start-ssh-agent
        end
    end

    if test -n "$FORCE_SSH_AGENT"
        set -e SSH_AUTH_SOCK
        start-ssh-agent
    end

    if not contains $HOME/bin $PATH
        set -gx PATH $HOME/bin $PATH
    end

    add-to-path /run/current-system/sw/bin
    add-to-path /opt/homebrew/bin
    add-to-path ${pkgs.direnv}/bin
    add-to-path /Applications/Hammerspoon.app/Contents/Frameworks/hs

    test -e $HOME/.1password/session.sh && test -r $HOME/.1password/session.sh && grep -qE '^OP_SESSION' $HOME/.1password/session.sh && export (head -1 $HOME/.1password/session.sh)
    alias op-unlock="${opWrapper}/bin/op-unlock"
    alias op="${opWrapper}/bin/op-wrapper"

    function geoiplookup
        ${pkgs.curl}/bin/curl -s ipinfo.io/$argv[1]
    end

    function nix-flake-init
        ${pkgs.nix}/bin/nix flake init -t gitlab:kylesferrazza/nix-flake-templates
    end

    source ${./nix.fish}
    source ${aws_config}

    mkdir -p ~/.config/fish

    test -e ~/.config/fish/machine.fish && source ~/.config/fish/machine.fish || true
    test -e ~/.config/fish/config.fish && source ~/.config/fish/config.fish
    test -e ~/.config/fish/custom.fish && source ~/.config/fish/custom.fish || true
  '';
  fishExe = pkgs.writeShellScriptBin "fish" ''
    ${pkgs.fish}/bin/fish --init-command="source ${fish_config}" $@
  '';
  myClip =
    if pkgs.stdenv.hostPlatform.isDarwin
    then
      pkgs.writeShellScript "myClip" ''
        stdin=$(cat)
        /usr/bin/printf "%s" "$stdin" | /usr/bin/pbcopy
      ''
    else
      pkgs.writeShellScript "myClip" ''
        stdin=$(cat)
        env | grep -qE '^WAYLAND' && clipboard_command="${pkgs.wl-clipboard}/bin/wl-copy"
        if env | grep -qE '^DISPLAY'
        then
          clipboard_command="${pkgs.xclip}/bin/xclip -sel clip"
        else
          clipboard_command="${pkgs.tmux}/bin/tmux loadb -"
        fi
        printf "%s" "$stdin" | $clipboard_command
      '';
  clipConf = ''
    bind -T copy-mode-vi y send-keys -X copy-pipe-and-cancel "${myClip}"
    bind -T copy-mode-vi Enter send-keys -X copy-pipe-and-cancel "${myClip}"
  '';
  statusBar = pkgs.writeText "statusbar.tmux" ''
    set -g set-titles on
    set -g set-titles-string "#S: #{?#{==:#{pane_title},#{host}},#W,#{pane_title}}"

    set -g status-position bottom
    set -g status-style "bg=default fg=colour245"

    set -g status-left "#[fg=colour114,bold] #S #[default]  "
    set -g status-left-length 30

    set -g status-right "#{?#{==:#{pane_title},#{host}},,#[fg=colour110]#{=40:pane_title}  }#[fg=colour245]%H:%M  %d %b "
    set -g status-right-length 80

    setw -g window-status-current-format "#[bg=colour110,fg=colour234,bold] #I #W #[default]"
    setw -g window-status-format         "#[fg=colour243]#I #W"
    setw -g window-status-separator      "#[fg=colour242] · "
  '';
  tmuxConf = pkgs.writeText "tmux.conf" ''
    set -g default-shell ${fishExe}/bin/fish

    source-file ${statusBar}

    unbind-key C-b
    set-option -g prefix C-a

    set-option -ga terminal-overrides ",xterm-termite:Tc"

    set-option -g base-index 1

    set-option -g status-keys vi
    set-window-option -g mode-keys vi

    set-option -g history-limit 10000

    set-window-option -g xterm-keys on

    set -g default-terminal "screen-256color"

    set -sg escape-time 0

    bind h select-pane -L
    bind j select-pane -D
    bind k select-pane -U
    bind l select-pane -R

    unbind % # Split vertically
    unbind '"' # Split horizontally

    bind-key | split-window -h -c "#{pane_current_path}"
    bind-key - split-window -v -c "#{pane_current_path}"

    bind-key S command-prompt -p ssh: "new-window -n %1 'ssh %1'"
    bind-key M command-prompt -p mosh: "new-window -n %1 'mosh %1'"

    set -g mouse on

    bind -n WheelUpPane   select-pane -t= \; copy-mode -e \; send-keys -M
    bind -n WheelDownPane select-pane -t= \;                 send-keys -M

    bind a send-prefix
    bind-key -T copy-mode-vi 'v' send-keys -X begin-selection

    ${clipConf}

    if-shell "[ -n \"$SSH_TTY\" ]" "set -g status off"
    if-shell "[ -n \"$SSH_CONNECTION\" ]" "set -g status off"
    if-shell "[ -n \"$FORCE_TMUX_STATUS\" ]" "set -g status on"
  '';
  zellijEditor = pkgs.writeShellScript "editor" ''
    if ${pkgs.which}/bin/which hx &>/dev/null
    then
      hx $@
    else
      ${pkgs.vim}/bin/vim $@
    fi
  '';
  zellijConf = pkgs.writeText "config.yaml" ''
    default_shell "${fishExe}/bin/fish"
    theme "nord"
    simplified_ui true
    pane_frames false
    scrollback_editor "${zellijEditor}"
  '';
  ghosttyOsConf =
    if pkgs.stdenv.hostPlatform.isDarwin
    then ''
      font-size = 16
      macos-window-shadow = false
      quick-terminal-space-behavior = remain
      initial-window = false
      keybind = global:ctrl+grave_accent=toggle_quick_terminal
      quick-terminal-animation-duration = 0.1
      quick-terminal-autohide = false
    ''
    else ''
      font-size = 14
    '';
  ghosttyConf = pkgs.writeText "config" ''
    theme = Nord
    command = ${pkgs.tmux}/bin/tmux -f ${tmuxConf}
    window-decoration = false
    auto-update = off
    quick-terminal-size = 90%
    ${ghosttyOsConf}
  '';
  ghosttyXdgDir = pkgs.stdenv.mkDerivation {
    name = "xdgDir";
    builder = pkgs.bash;
    args = [
      "-c"
      "${pkgs.coreutils}/bin/mkdir -p $out/ghostty; ${pkgs.coreutils}/bin/cp ${ghosttyConf} $out/ghostty/config;"
    ];
  };
in {
  fish = fishExe;
  ghostty = pkgs.writeShellScriptBin "ghostty" ''
    XDG_CONFIG_HOME=${ghosttyXdgDir} ${pkgs.ghostty}/bin/ghostty $@
  '';
  ghostty-config = ghosttyConf;
  tmux = pkgs.writeShellScriptBin "tmux" ''
    PATH=${pkgs.bashInteractive}/bin:$PATH
    if env | grep -i en_US
    then
      ${pkgs.tmux}/bin/tmux -f ${tmuxConf} $@
    else
      ${pkgs.tmux}/bin/tmux -u -f ${tmuxConf} $@
    fi
  '';
  zellij = pkgs.writeShellScriptBin "zellij" ''
    PATH=${pkgs.zellij}/bin:$PATH
    ${pkgs.zellij}/bin/zellij --config ${zellijConf} $@
  '';
  op-wrapper = opWrapper;
}
