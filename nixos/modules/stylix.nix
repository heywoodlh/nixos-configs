{ config, pkgs, lib, ... }:

let
  # Set originally in `./base/stylix.nix`
  # This file contains only NixOS specific config
  cfg = config.heywoodlh.stylix;
in {
  config = lib.mkIf cfg.enable {
    fonts = {
      enableDefaultPackages = true;
      fontDir.enable = true;
      enableGhostscriptFonts = true;
      packages = with pkgs; [
        # corefonts
        dejavu_fonts
        noto-fonts
        fira-code
        nerd-fonts.jetbrains-mono
        nerd-fonts.symbols-only
        jetbrains-mono
      ];
      fontconfig = let
        package = pkgs.font-awesome;
        faVer = lib.last (lib.strings.split "-" package.name);
        faMajor = lib.head (lib.strings.split "\\." faVer);
      in {
        defaultFonts = {
          serif = [
            "DejaVu Serif"
            "Font Awesome ${faMajor} Free"
          ];
          sansSerif = [
            "DejaVu Sans"
            "Font Awesome ${faMajor} Free"
          ];
          monospace = [
            "JetBrainsMono Nerd Font"
            "Font Awesome ${faMajor} Free"
          ];
          emoji = [ "Noto Color Emoji" ];
        };
      };
    };

    home-manager.users.${cfg.username} = { ... }: {
      # get rid of the god-awful orange
      # for some reason `stylix.targets.ashell.override` does not seem to work
      programs.ashell.settings.appearance = {
        danger_color = lib.mkForce "#d8dee9";
        workspace_colors = lib.mkForce [
          "#d8dee9"
          "#8aadf4"
        ];
      };
      fonts.fontconfig.enable = true;
      stylix.targets = {
        fuzzel.fonts.override = {
          sansSerif.name = "JetBrains Mono";
          sizes.popups = "14";
        };
      };
    };
  };
}
