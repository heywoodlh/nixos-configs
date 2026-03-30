{ config, pkgs, lib, ... }:

with lib;

let
  cfg = config.heywoodlh.stylix;
in {
  options.heywoodlh.stylix = {
    enable = mkOption {
      default = false;
      description = ''
        Enable heywoodlh Stylix configuration.
      '';
      type = types.bool;
    };
    theme = mkOption {
      default = "catppuccin-macchiato";
      description = ''
        Stylix theme.
      '';
      type = types.str;
    };
    username = mkOption {
      default = "heywoodlh";
      description = ''
        Username to apply home-manager configs to.
      '';
      type = types.str;
    };
  };

  config = mkIf cfg.enable {
    stylix = {
      enable = true;
      base16Scheme = "${pkgs.base16-schemes}/share/themes/${cfg.theme}.yaml";
      image = if pkgs.stdenv.isDarwin then ../assets/catppuccin-apple.png else ../assets/catppuccin-nix.png;
      polarity = "dark";
      fonts = {
        serif = {
          package = pkgs.dejavu_fonts;
          name = "DejaVu Serif";
        };
        sansSerif = {
          package = pkgs.dejavu_fonts;
          name = "DejaVu Sans";
        };
        monospace = {
          package = pkgs.nerd-fonts.jetbrains-mono;
          name = "JetBrainsMono Nerd Font";
        };
        emoji = {
          package = pkgs.noto-fonts-color-emoji;
          name = "Noto Color Emoji";
        };
      };
    };
    home-manager.users.${cfg.username} = { ... }: {
      stylix.targets = {
        librewolf.profileNames = [ "home-manager" ];
        # Don't configure Helix (using a transparent theme)
        helix.enable = false;
      };
    };
  };
}
