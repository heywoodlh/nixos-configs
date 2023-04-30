{ config, pkgs, home-manager, nur, ... }:

{
  home.stateVersion = "22.11";
  nix = {
    package = pkgs.nix;
    extraOptions = ''
      experimental-features = nix-command flakes
    '';
  };

  # Import nur as nixpkgs.overlays
  nixpkgs.overlays = [ 
    nur.overlay 
  ];
  
  programs.alacritty = {
    enable = true;
    settings = {
      colors = {
        primary = {
          background = "#2e3440";
          foreground = "#d8dee9";
          dim_foreground = "#a5abb6";
        };
        cursor = {
          text = "#2e3440";
          cursor = "#d8dee9";
        };
        vi_mode_cursor = {
          text = "#2e3440";
          cursor = "#d8dee9";
        };
        selection = {
          text = "CellForeground";
          background = "#4c566a";
        };
        search = {
          matches = {
            foreground = "CellBackground";
            background = "#88c0d0";
          };
        };
        footer_bar = {
          background = "#434c5e";
          foreground = "#d8dee9";
        };
        normal = {
          black = "#3b4252";
          red = "#bf616a";
          green = "#a3be8c";
          yellow = "#ebcb8b";
          blue = "#81a1c1";
          magenta = "#b48ead";
          cyan = "#88c0d0";
          white = "#e5e9f0";
        };
        bright = {
          black = "#4c566a";
          red = "#bf616a";
          green = "#a3be8c";
          yellow = "#ebcb8b";
          blue = "#81a1c1";
          magenta = "#b48ead";
          cyan = "#8fbcbb";
          white = "#eceff4";
        };
        dim = {
          black = "#373e4d";
          red = "#94545d";
          green = "#809575";
          yellow = "#b29e75";
          blue = "#68809a";
          magenta = "#8c738c";
          cyan = "#6d96a5";
          white = "#aeb3bb";
        };
      };
      
      font = {
        normal = {
          family = "JetBrainsMono Nerd Font Mono";
          style = "Medium";
        };
        bold = {
          family = "JetBrainsMono Nerd Font Mono";
          style = "Medium";
        };
        italic = {
          family = "JetBrainsMono Nerd Font Mono";
          style = "Medium";
        };
        bold_italic = {
          family = "JetBrainsMono Nerd Font Mono";
          style = "Medium";
        };
        size = 14;
        builtin_box_drawing = true;
      };
      window = {
        decorations = "none";
      };
      shell = {
        program = ".nix-profile/bin/tmux";
      };
    };
  }; 
  programs.password-store = {
    enable = true;
    package = pkgs.pass.withExtensions (exts: [ exts.pass-otp ]);
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
  };
  programs.vim = {
    enable = true;
    extraConfig = ''
      if winheight(0) >= 35
      	set termwinsize=10x0
      	set confirm
      	set splitbelow
      end
      let g:airline_statusline_ontop=1
      let g:airline#extensions#tabline#enabled = 1
      " Nerdfonts
      let g:airline_powerline_fonts = 1
      " Clear terminal buffer on exit (without it, Airline messes up shell)
      set t_ti= t_te=
      " Set Nord Airline Theme
      let g:airline_theme='nord'
      " Enable ale with airline
      let g:airline#extensions#ale#enabled = 1
  
      syntax on
      
      colorscheme nord
      
      filetype plugin indent on
      let g:mapleader = "\<Space>"
      let g:maplocalleader = ','
      nnoremap <silent> <leader>      :<c-u>WhichKey '<Space>'<CR>
      nnoremap <silent> <localleader> :<c-u>WhichKey  ','<CR>
      map <C-n> :NERDTreeToggle<CR>
      
      set number
      
      " Start Nerdtree only if width is greater than or equal to 80 columns
      "if winwidth(0) >= 100
      "	let g:NERDTreeWinSize=winwidth(0)/6
      "	autocmd VimEnter * NERDTree | wincmd p	
      "endif
      " Start NERDTree when Vim starts with a directory argument.
      autocmd StdinReadPre * let s:std_in=1
      autocmd VimEnter * if argc() == 1 && isdirectory(argv()[0]) && !exists('s:std_in') |
          \ execute 'NERDTree' argv()[0] | wincmd p | enew | execute 'cd '.argv()[0] | endif
      
      " Vim-indentline config
      let g:indentLine_char = '⦙'
      set shiftwidth=4
      let g:vim_json_conceal=0
      let g:vim_json_syntax_conceal = 0
      let g:markdown_syntax_conceal=0
      augroup filetype_indent
        autocmd!
        autocmd FileType dockerfile let g:indentLine_enabled = 0
      augroup END
      
      " Custom keybinds
      nnoremap zz :wa <bar> :qa!<CR>
      nnoremap zq <bar> :qa!<CR>
      map <silent> <C-y> :w! ~/tmp/vimbuf <CR>:silent !cat ~/tmp/vimbuf <Bar> pbcopy<CR>:redraw!<CR>
      map <silent> <C-t> :term ++kill=term<CR>
      map <silent> <C-o> :FZF $HOME<CR>
      map <silent> <C-l> :set invnumber<CR>
      
      "" Vim-markdown-preview toggle
      nnoremap mdp :Glow<CR>
      
      command NoComments %s/#.*\n//g
      command GitAdd :w! <bar> !git add -v %
      command GitCommit !$gitmessage = ($gitmessage = read-host -prompt "commit message") && git commit -s -m ''${gitmessage}
      command GitPush !gpsup
      
      nnoremap ga :GitAdd<CR>
      nnoremap gc :GitCommit<CR>
      nnoremap gp :GitPush<CR>
      nnoremap nc :NoComments<CR>
      
      " Folding
      set foldmethod=syntax
      set foldlevel=99
      
      " Show matching characters like paranthesis, brackets, etc.
      set showmatch
      
      " tell vim to keep a backup file
      set backup
      " tell vim where to put its backup files
      set backupdir=~/tmp
      " tell vim where to put swap files
      set dir=~/tmp
      
      " Cursor settings:
      
      "  1 -> blinking block
      "  2 -> solid block 
      "  3 -> blinking underscore
      "  4 -> solid underscore
      "  5 -> blinking vertical bar
      "  6 -> solid vertical bar
      
      " back to line cursor when in normal mode
      let &t_SI.="\e[5 q" "SI = INSERT mode
      let &t_SR.="\e[5 q" "SR = REPLACE mode
      let &t_EI.="\e[5 q" "EI = NORMAL mode (ELSE)
      
      " Convert tabs to spaces
      set tabstop=8 softtabstop=0 expandtab shiftwidth=4 smarttab
      
      " Ignore case
      set ignorecase smartcase
    '';
  
    plugins = with pkgs.vimPlugins; [
      ale
      base16-vim
      colorizer
      copilot-vim
      fugitive
      glow-nvim
      indentLine
      nerdtree
      nord-vim
      SudoEdit-vim
      vim-airline
      vim-airline-themes
      vim-gitgutter
      vim-json
      vim-lastplace
      vim-sensible
      vim-sneak
      vim-terraform
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

      if [[ -e ~/.zsh.d/custom ]]
      then
        source ~/.zsh.d/custom
      fi

      check_ssh () {
        ssh_symbol=""
        [[ -n $SSH_CONNECTION ]] && echo $fg[red] $(echo "''${ssh_symbol}[$(whoami)@$(hostname)]")
      }

      theme_precmd () {
        check_ssh
        vcs_info
      }
      
      # Set ssh-unlock if it's not already set
      alias | grep -q ssh-unlock || alias ssh-unlock="bw get item ssh/id_rsa | jq -r .notes | ssh-add -t 4h -"
    '';
  
    # Enable oh-my-zsh
    oh-my-zsh = {
      enable = true;
      plugins = [
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
        "rbw"
        "ssh-agent"
        "sudo"
      ];
      theme = "apple";
    };
  };
}