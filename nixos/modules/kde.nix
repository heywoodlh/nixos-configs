{ config, pkgs, lib, plasma-manager, ... }:
with lib;

let
  cfg = config.heywoodlh.nixos.kde;
in {
  options.heywoodlh.nixos.kde = {
    enable = mkOption {
      default = false;
      description = ''
        Enable heywoodlh sunshine configuration.
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
    services.xserver.enable = true;

    services.desktopManager.plasma6.enable = true;
    programs.ssh.askPassword = lib.mkForce "${pkgs.kdePackages.ksshaskpass}/bin/ksshaskpass";

    home-manager = {
      users."${cfg.user}" = { ... }: {
        imports = [
          (plasma-manager + /modules/default.nix)
        ];
        programs.plasma = {
          enable = true;
          desktop.icons.size = 1;
          session = {
            sessionRestore.restoreOpenApplicationsOnLogin = "startWithEmptySession";
            general.askForConfirmationOnLogout = false;
          };
        };
      };
    };
  };
}
