{ config, pkgs, lib, ... }:

let
  # Set originally in `./base/stylix.nix`
  # This file contains only NixOS specific config
  cfg = config.heywoodlh.stylix;
in {
  config = lib.mkIf cfg.enable {
    stylix = {
      targets.plymouth = {
        logo = ../../assets/catppuccin-nix.png;
        logoAnimated = false;
      };
      # kmscon options (extraConfig, fonts) were removed in newer nixpkgs
      targets.kmscon.enable = false;
    };
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
      fonts.fontconfig.enable = true;
    };
  };
}
