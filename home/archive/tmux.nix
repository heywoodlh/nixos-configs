{ config, pkgs, ... }:

{
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

    # vim-copy
    bind-key -T copy-mode-vi 'v' send-keys -X begin-selection
    bind-key -T copy-mode-vi 'y' send-keys -X copy-pipe-and-cancel 'pbcopy'

    # Status bar
    set -g status off
    #set -g status-left "#[fg=black,bg=blue,bold] #S #[fg=blue,bg=black,nobold,noitalics,nounderscore]"
    #set -g status-right "#{prefix_highlight}#[fg=brightblack,bg=black,nobold,noitalics,nounderscore]#[fg=white,bg=brightblack] %Y-%m-%d #[fg=white,bg=brightblack,nobold,noitalics,nounderscore]#[fg=white,bg=brightblack] %H:%M #[fg=cyan,bg=brightblack,nobold,noitalics,nounderscore]#[fg=black,bg=cyan,bold] #H "
  '';
  plugins = with pkgs.tmuxPlugins; [
    nord
  ];
}
