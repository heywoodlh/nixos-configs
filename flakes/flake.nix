{
  description = "meta-flake";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    nixpkgs-stable.url = "github:NixOS/nixpkgs/nixos-25.05";
    flake-utils.url = "github:numtide/flake-utils";
    fish-flake = {
      url = "./fish";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.flake-utils.follows = "flake-utils";
    };
    vim-flake = {
      url = "./vim";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.flake-utils.follows = "flake-utils";
    };
    helix-src = {
      url = "github:alevinval/helix/issue-2719";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.flake-utils.follows = "flake-utils";
    };
    helix-flake = {
      url = "./helix";
      inputs.nixpkgs.follows = "nixpkgs-stable";
      inputs.flake-utils.follows = "flake-utils";
      inputs.helix-src.follows = "helix-src";
    };
    git-flake = {
      url = "./git";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.flake-utils.follows = "flake-utils";
    };
    jujutsu-flake = {
      url = "./jj";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.flake-utils.follows = "flake-utils";
    };
    vscode-flake = {
      url = "./vscode";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.flake-utils.follows = "flake-utils";
      inputs.fish-flake.follows = "fish-flake";
    };
    nushell-flake = {
      url = "./nushell";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.flake-utils.follows = "flake-utils";
    };
    op-flake = {
      url = "./1password";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.flake-utils.follows = "flake-utils";
    };
    lima-flake = {
      url = "./nixos-lima";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.flake-utils.follows = "flake-utils";
    };
    chromium-widevine-flake = {
      url = "./chromium-widevine";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    vicinae-nix = {
      url = "github:vicinaehq/vicinae";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.systems.follows = "flake-utils/systems";
    };
    gnome-flake = {
      url = "./gnome";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.nixpkgs-stable.follows = "nixpkgs-stable";
      inputs.flake-utils.follows = "flake-utils";
      inputs.fish-flake.follows = "fish-flake";
      inputs.vim-flake.follows = "vim-flake";
      inputs.vicinae-nix.follows = "vicinae-nix";
    };
    zen-browser-flake = {
      url = "./zen-browser";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.flake-utils.follows = "flake-utils";
    };
    tabby-flake = {
      url = "./tabby";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.flake-utils.follows = "flake-utils";
    };
    ttyd-flake = {
      url = "./ttyd-nerd";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.flake-utils.follows = "flake-utils";
    };
  };

  outputs = inputs @ {
    self,
    nixpkgs,
    nixpkgs-stable,
    flake-utils,
    fish-flake,
    git-flake,
    jujutsu-flake,
    nushell-flake,
    vim-flake,
    helix-src,
    helix-flake,
    vscode-flake,
    op-flake,
    lima-flake,
    chromium-widevine-flake,
    vicinae-nix,
    gnome-flake,
    zen-browser-flake,
    tabby-flake,
    ttyd-flake,
  }:
    flake-utils.lib.eachDefaultSystem (system: let
      pkgs = nixpkgs.legacyPackages.${system};
    in {
      packages = {
        fish = fish-flake.packages.${system}.fish;
        nushell = nushell-flake.packages.${system}.nushell;
        git = git-flake.packages.${system}.git;
        jujutsu = jujutsu-flake.packages.${system}.jujutsu;
        jujutsu-config = jujutsu-flake.packages.${system}.config;
        tmux = fish-flake.packages.${system}.tmux;
        ghostty = fish-flake.packages.${system}.ghostty;
        ghostty-config = fish-flake.packages.${system}.ghostty-config;
        vim = vim-flake.packages.${system}.vim;
        helix = helix-flake.packages.${system}.helix;
        helix-wrapper = helix-flake.packages.${system}.helix-wrapper;
        helix-config = helix-flake.packages.${system}.helix-config;
        vscode = vscode-flake.packages.${system}.default;
        vscode-userdir = vscode-flake.packages.${system}.user-dir;
        vscode-bin = vscode-flake.packages.${system}.code-bin;
        op = op-flake.packages.${system}.op;
        op-desktop-setup = op-flake.packages.${system}.op-desktop-setup;
        nixos-vm = lima-flake.packages.${system}.runVm;
        lima-nixos-img = lima-flake.packages.${system}.img;
        chromium-widevine = chromium-widevine-flake.packages.aarch64-linux.chromium-widevine;
        gnome = gnome-flake.packages.${system}.gnome-desktop-setup;
        gnome-dconf = gnome-flake.packages.${system}.dconf;
        gnome-install-extensions = gnome-flake.packages.${system}.gnome-install-extensions;
        zen-browser = zen-browser-flake.packages.${system}.default;
        tabby = tabby-flake.packages.${system}.tabby-wrapper;
        zellij = fish-flake.packages.${system}.zellij;
        ttyd = ttyd-flake.packages.${system}.ttyd;
        vicinae = gnome-flake.packages.${system}.vicinae;
        op-wrapper = fish-flake.packages.${system}.op-wrapper;
      };
      formatter = pkgs.alejandra;
    });
}
