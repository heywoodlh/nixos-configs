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
    # Jovian-NixOS builds pipewire-jupiter by taking nixpkgs pipewire as a base and
    # overriding the source with their fork. The nixpkgs 0060-libjack-path.patch fails
    # to apply to the Jovian fork source, so strip it from pipewire-jupiter directly.
    # Using mkAfter so this overlay runs after Jovian's (which defines pipewire-jupiter),
    # and the base pipewire package is left untouched to preserve binary cache hits.
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

    heywoodlh.nixos = {
      kde = {
        enable = true;
        user = cfg.user;
      };
      gaming = {
        enable = true;
        user = cfg.user;
      };
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
      # Use Decky loader if Gamescope is enabled for Steam Deck like UX
      decky-loader = {
        enable = true;
        user = cfg.user;
        extraPackages = with pkgs; [
          power-profiles-daemon
          inotify-tools
          libpulseaudio
          coreutils
          gamescope
          gamemode
          mangohud
          pciutils
          systemd
          gnugrep
          python3
          gnused
          procps
          gawk
          file
        ];
        extraPythonPackages = pythonPkgs: with pythonPkgs; [
          click
        ];
      };
    };
  };
}
