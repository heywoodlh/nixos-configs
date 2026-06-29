{ config, pkgs, lib, plasma-manager, ... }:
with lib;

let
  cfg = config.heywoodlh.nixos.kde;
  win11-sddm = pkgs.stdenv.mkDerivation {
    pname = "sddm-theme-win11";
    version = "6482945";
    src = pkgs.fetchFromGitHub {
      owner = "syrupderg";
      repo = "win11-sddm-theme";
      rev = "6482945197d700aee806b8eb98c3263cba6f3ba1";
      hash = "sha256-e1uVSwvGxjQFV/crwo9Eh8vMSltvNu29BZkzrw5E8dk=";
    };
    dontBuild = true;
    installPhase = ''
      mkdir -p $out/share/sddm/themes
      cp -aR $src $out/share/sddm/themes/win11
    '';
  };
in {
  options.heywoodlh.nixos.kde = {
    enable = mkOption {
      default = false;
      description = ''
        Enable heywoodlh KDE configuration.
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
    windows = mkOption {
      default = false;
      description = ''
        Configure KDE to look and feel like Windows.
      '';
      type = types.bool;
    };
  };

  config = mkIf cfg.enable {
    services.xserver.enable = true;

    services.desktopManager.plasma6.enable = true;
    programs.ssh.askPassword = lib.mkForce "${pkgs.kdePackages.ksshaskpass}/bin/ksshaskpass";

    environment.systemPackages = lib.optionals (cfg.windows) [
      win11-sddm
    ];

    services.displayManager = lib.optionalAttrs (cfg.windows) {
      gdm.enable = lib.mkForce false;
      defaultSession = lib.mkForce "plasma";
      sddm = {
        enable = true;
        wayland.enable = true;
        settings.Theme.Current = "win11";
      };
    };

    home-manager = {
      users."${cfg.user}" = { ... }: {
        imports = [
          (plasma-manager + /modules/default.nix)
        ];

        heywoodlh.home.kde-windows = {
          enable = true;
          active = true;
        };

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
