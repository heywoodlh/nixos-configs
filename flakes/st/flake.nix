{
  description = "heywoodlh suckless terminal flake";

  inputs.nixpkgs.url = "github:NixOS/nixpkgs/fa804edfb7869c9fb230e174182a8a1a7e512c40"; # pin nixpkgs version
  inputs.flake-utils.url = "github:numtide/flake-utils";
  inputs.fish-flake.url = ../fish;

  outputs = { self, nixpkgs, flake-utils, fish-flake }:
    flake-utils.lib.eachDefaultSystem (system:
    let
      pkgs = nixpkgs.legacyPackages.${system};
      myZellij = fish-flake.packages.${system}.zellij;
      mySt = (pkgs.st.overrideAttrs (oldAttrs: rec {
        patches = [
          # Nord theme
          ./patches/st-nordtheme-0.8.5.diff
          # Disable decorations
          ./patches/st-no_window_decorations-0.8.5-20220824-72fd327.diff
          # Scrollback
          ./patches/st-scrollback-0.8.5.diff
          # Hide cursor (conflicts with alpha)
          #./patches/st-hidecursor-0.8.3.diff
          # Blinking cursor
          ./patches/st-blinking_cursor-20230819-3a6d6d7.diff
          # Universal scroll
          ./patches/st-universcroll-0.8.4.diff
          # Font size flag
          ./patches/st-defaultfontsize-20210225-4ef0cbd.diff
          # Transparency
          ./patches/st-alpha-20220206-0.8.5.diff
        ];})
      );
    in {
      packages = rec {
          st = pkgs.writeShellScriptBin "st" ''
            ${pkgs.fontconfig}/bin/fc-list | grep -iq jetbrains && export extra_args="-f 'JetBrainsMono Nerd Font Mono:size=14'"
            eval ${mySt}/bin/st $extra_args $@ ${myZellij}/bin/zellij
          '';
          default = st;
        };
      }
    );
}
