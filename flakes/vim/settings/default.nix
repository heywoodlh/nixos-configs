{ callPackage, mcphub, mcphub-nvim, ...}:

let
  modFiles = [
    # Plugins
    ./ale.nix
    ./base16-vim.nix
    ./betterwhitespace.nix
    ./colorizer.nix
    ./cursor.nix
    ./fugitive.nix
    ./git.nix
    ./gitgutter.nix
    ./glow.nix
    ./indentline.nix
    ./json.nix
    ./languages.nix
    ./lastplace.nix
    ./llm.nix
    ./localvimrc.nix
    ./nerdtree.nix
    ./oil.nix
    ./os-specific.nix
    ./pets.nix
    ./sensible.nix
    ./shell.nix
    ./theme.nix
    ./which-key.nix
    # Base vim config
    ./vimrc.nix
  ];

  importModFile = f: callPackage f { inherit mcphub; inherit mcphub-nvim; };
in map importModFile modFiles
