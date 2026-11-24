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
  isDarwin = pkgs.stdenv.hostPlatform.isDarwin;
  hostname = if isDarwin then "/bin/hostname -s" else "${pkgs.hostname}/bin/hostname -s";
  soloist = if cfg.package == null then "/opt/homebrew/bin/soloist" else "${cfg.package}/bin/soloist";
  launch = pkgs.writeShellScript "spotify-soloist" ''
    set -euo pipefail
    soloist="${soloist}"
    ${optionalString (cfg.package == null) ''
      if [[ ! -x "$soloist" ]]
      then
        echo "spotify-soloist: $soloist not found, install the spotify-soloist cask" >&2
        exit 0
      fi
    ''}
    if [[ ! -s "${cfg.credentialsFile}" ]]
    then
      echo "spotify-soloist: no API key at ${cfg.credentialsFile}" >&2
      exit 0
    fi
    exec "$soloist" --device-name "$(${hostname})" --api-key "$(${pkgs.coreutils}/bin/cat '${cfg.credentialsFile}')"
  '';
in
{
  options.heywoodlh.home.spotify-soloist = {
    enable = mkOption {
      default = false;
      description = "Enable Spotify Soloist as a Spotify Connect device.";
      type = types.bool;
    };
    credentialsFile = mkOption {
      default = "${homeDir}/.local/share/spotify-soloist/password.txt";
      defaultText = literalExpression ''"''${config.home.homeDirectory}/.local/share/spotify-soloist/password.txt"'';
      description = "File holding the Soloist API key; the service stays stopped until it exists.";
      type = types.str;
    };
    package = mkOption {
      default = if isDarwin then null else edgePkgs.soloist;
      defaultText = literalExpression "if pkgs.stdenv.hostPlatform.isLinux then nixpkgs-edge.legacyPackages.\${pkgs.stdenv.hostPlatform.system}.soloist else null";
      description = "Soloist package. Defaults to null on Darwin because only the Homebrew cask ships a macOS build; the Homebrew binary at /opt/homebrew/bin/soloist is used instead.";
      type = types.nullOr types.package;
    };
  };

  config = mkIf cfg.enable (mkMerge [
    (mkIf isDarwin {
      launchd.agents.spotify-soloist = {
        enable = true;
        config = {
          ProgramArguments = [ "${launch}" ];
          RunAtLoad = true;
          KeepAlive.SuccessfulExit = false;
          WatchPaths = [ cfg.credentialsFile ];
        };
      };
    })

    (mkIf (!isDarwin) {
      systemd.user.services.spotify-soloist = {
        Unit = {
          Description = "Spotify Soloist Connect device";
          After = [
            "pipewire.service"
            "network-online.target"
          ];
          ConditionPathExists = cfg.credentialsFile;
        };
        Service = {
          ExecStart = launch;
          Restart = "on-failure";
          RestartSec = 12;
        };
        Install.WantedBy = [ "default.target" ];
      };

      systemd.user.paths.spotify-soloist = {
        Path = {
          PathExists = cfg.credentialsFile;
          Unit = "spotify-soloist.service";
        };
        Install.WantedBy = [ "default.target" ];
      };
    })
  ]);
}
