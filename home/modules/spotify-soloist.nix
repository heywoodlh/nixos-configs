{
  config,
  lib,
  pkgs,
  nixpkgs-edge,
  ...
}:

with lib;

let
  cfg = config.heywoodlh.home.spotify-soloist;
  edgePkgs = import nixpkgs-edge {
    system = pkgs.stdenv.hostPlatform.system;
    config.allowUnfree = true;
  };
  homeDir = config.home.homeDirectory or "$HOME";
  credentialsFile = replaceStrings [ "$HOME" ] [ homeDir ] cfg.credentialsFile;
in
{
  options.heywoodlh.home.spotify-soloist = {
    enable = mkOption {
      default = false;
      description = "Enable Spotify Soloist as a Spotify Connect device.";
      type = types.bool;
    };
    credentialsFile = mkOption {
      default = "$HOME/.local/share/spotify-soloist/password.txt";
      description = "File holding the Soloist API key; the service stays stopped until it exists.";
      type = types.str;
    };
  };

  config = mkIf (cfg.enable && pkgs.stdenv.hostPlatform.isLinux) {
    systemd.user.services.spotify-soloist = {
      Unit = {
        Description = "Spotify Soloist Connect device";
        After = [
          "pipewire.service"
          "network-online.target"
        ];
        ConditionPathExists = credentialsFile;
      };
      Service = {
        ExecStart = pkgs.writeShellScript "spotify-soloist" ''
          exec ${edgePkgs.soloist}/bin/soloist \
            --device-name "$(${pkgs.coreutils}/bin/hostname)" \
            --api-key "$(${pkgs.coreutils}/bin/cat '${credentialsFile}')"
        '';
        Restart = "on-failure";
        RestartSec = 12;
      };
      Install.WantedBy = [ "default.target" ];
    };

    systemd.user.paths.spotify-soloist = {
      pathConfig = {
        PathExists = credentialsFile;
        Unit = "spotify-soloist.service";
      };
      Install.WantedBy = [ "default.target" ];
    };
  };
}
