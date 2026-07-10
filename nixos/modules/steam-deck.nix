{ config, pkgs, lib, nixpkgs, ... }:

with lib;

let
  cfg = config.heywoodlh.nixos.steam-deck;
in {
  options.heywoodlh.nixos.steam-deck = {
    enable = mkOption {
      default = false;
      description = ''
        Enable heywoodlh Steam Deck configuration.
      '';
      type = types.bool;
    };
    user = mkOption {
      default = "heywoodlh";
      description = ''
        User for heywoodlh configuration.
      '';
      type = types.str;
    };
  };

  config = mkIf cfg.enable {
    # Overrides for jovian
    nixpkgs.overlays = mkAfter [
      (final: prev: {
        _1password-gui = (import nixpkgs {
          inherit (prev.stdenv.hostPlatform) system;
          config.allowUnfree = true;
        })._1password-gui;

        pipewire-jupiter = prev.pipewire-jupiter.overrideAttrs (old: {
          patches = builtins.filter
            (p: !(lib.hasSuffix "0060-libjack-path.patch" (builtins.toString p)))
            (old.patches or []);
        });
      })
    ];

    heywoodlh = {
      sshd = {
        enable = true;
        tailscale = true;
      };
      nixos = {
        kde = {
          enable = true;
          user = cfg.user;
        };
        gaming = {
          enable = true;
          user = cfg.user;
        };
        moonlight = {
          enable = true;
          user = cfg.user;
        };
      };
    };

    stylix.targets.plymouth.enable = mkForce false;

    # Steam Deck uses KDE, not GNOME — disable Stylix's GNOME target to avoid
    # fetching gnome-shell source unnecessarily
    home-manager.users.${cfg.user} = { ... }: {
      stylix.targets.gnome.enable = false;
    };

    # Jovian-NixOS provides its own gamescope; disable the nixpkgs one to avoid conflicts
    programs.gamescope.enable = mkForce false;

    services.displayManager = {
      gdm.enable = mkForce false;
      defaultSession = mkForce "gamescope-wayland";
      sddm = {
        enable = true;
        wayland.enable = true;
      };
    };

    # No need for extra DE stuff on Deck
    heywoodlh.hyprland = mkForce false;
    heywoodlh.cosmic = mkForce false;

    jovian = {
      steam = {
        enable = true;
        autoStart = true;
        user = cfg.user;
        desktopSession = "plasma";
      };
      devices.steamdeck.enable = true;
    };
  };
}
