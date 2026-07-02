{ config, lib, ... }:

with lib;
with lib.types;

let
  cfg = config.heywoodlh.darwin.defaults;
  userType = submodule {
    options = {
      name = mkOption {
        default = "heywoodlh";
        description = "Username for heywoodlh defaults.";
        type = str;
      };
      description = mkOption {
        default = "Spencer Heywood";
        description = "Full name of user for heywoodlh defaults.";
        type = str;
      };
      uid = mkOption {
        default = 501;
        description = "UID for user for heywoodlh defaults.";
        type = int;
      };
      homeDir = mkOption {
        default = "/Users/${config.heywoodlh.darwin.defaults.user.name}";
        description = "Home directory for user for heywoodlh defaults.";
        type = path;
      };
    };
  };
in {
  options.heywoodlh.darwin.defaults = {
    enable = mkOption {
      default = false;
      description = "Enable heywoodlh defaults.";
      type = bool;
    };
    user = mkOption {
      description = "User for heywoodlh configuration.";
      type = userType;
    };
  };

  config = mkIf cfg.enable {
    nix.settings = {
      auto-optimise-store = false; # Breaks things
    };

    homebrew = {
      enable = true;
      onActivation = {
        autoUpdate = true;
        upgrade = true;
        cleanup = "zap";
        extraFlags = [
          "--force-cleanup"
        ];
      };
    };

    heywoodlh.stylix = {
      enable = true;
      username = cfg.user.name;
    };
    heywoodlh.darwin = {
      sketchybar.enable = true;
      yabai.enable = true;
      choose-launcher = {
        enable = false; # keeping around for documentation
        user = "${cfg.user.name}";
      };
      raycast = {
        enable = false;
        user = "${cfg.user.name}";
      };
    };
    services.container.enable = true;

    home-manager.users.${cfg.user.name} = {
      heywoodlh.home = {
        darwin = {
          nord-terminal = true;
          protondrive = true;
          defaults = {
            enable = true;
            screenshotDir = "${cfg.user.homeDir}/Pictures/screenshots/${config.networking.hostName}";
          };
        };

        # Run Lima VM always in background
        lima = {
          enable = true;
          docker = {
            enable = true;
            context = true;
          };
          nixos = {
            enable = true;
            nixos-rebuild = true;
          };
        };
      };
    };
  };
}
