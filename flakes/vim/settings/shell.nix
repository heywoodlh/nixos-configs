{ vimPlugins, writeText, writeShellScriptBin, fish, starship, direnv, coreutils, ncurses5, ... }:

let
  starship_config = writeText "starship.toml" ''
    [character]
    success_symbol = '[❯](bold white)'

    [container]
    disabled = true
  '';
  fish_config = writeText "profile.fish" ''
    # Source default nix profile if exists
    test -e /nix/var/nix/profiles/default/etc/profile.d/nix.fish && source /nix/var/nix/profiles/default/etc/profile.d/nix.fish || true

    # Function to add a directory to $PATH
    # Only if exists
    function add-to-path
        if not contains $argv[1] $PATH
            set -gx PATH $argv[1] $PATH
        end
    end

    add-to-path $HOME/bin
    add-to-path /run/current-system/sw/bin
    add-to-path /opt/homebrew/bin

    # Special stuff for appimage to work
    add-to-path ${coreutils}/bin
    add-to-path ${ncurses5}/bin

    # Starship
    set -gx STARSHIP_CONFIG "${starship_config}"
    ${starship}/bin/starship init fish | source

    # Direnv
    eval (${direnv}/bin/direnv hook fish)

    fish_config theme choose Nord
    set fish_greeting ""
  '';
  fish_bin = writeShellScriptBin "fish" ''
    ${fish}/bin/fish --init-command="source ${fish_config}" $@
  '';
in {
  plugins = with vimPlugins; [ vim-fish toggleterm-nvim ];
  rc = ''
    if executable("fish")
      " Placeholder because I don't know how to do 'if not'
    else
      set shell=${fish_bin}/bin/fish
    endif
    lua << EOF
      require("toggleterm").setup{
        open_mapping = [[<c-t>]],
        start_in_insert = true,
        insert_mappings = true,
        terminal_mappings = true,
        direction = 'float',
        hide_numbers = true,
        autochdir = true,
      }
    EOF
  '';
}
