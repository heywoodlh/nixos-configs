{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.heywoodlh.hyprland;
  username = config.heywoodlh.defaults.user.name;
  tailscaleBin = "/run/current-system/sw/bin/tailscale";
  tailscaleRoot = "${pkgs.coreutils}/bin/env SHELL=/run/current-system/sw/bin/bash /run/wrappers/bin/pkexec ${pkgs.bash}/bin/bash -c 'exec \"$0\" \"$@\"' ${tailscaleBin}";
  tailscaledActive = "/run/current-system/sw/bin/systemctl is-active --quiet tailscaled.service";
  tailscaleStatusScript = pkgs.writeShellScriptBin "tailscale-status.sh" ''
    while true; do
      if ! ${tailscaledActive}; then
        ${pkgs.jq}/bin/jq -cn '{text: "", alt: "inactive"}'
        sleep 5
        continue
      fi
      status=$(${tailscaleBin} status --json 2>/dev/null)
      state=$(${pkgs.jq}/bin/jq -r '.BackendState // "Stopped"' <<<"$status")
      exit_node=$(${pkgs.jq}/bin/jq -r '[.Peer[]? | select(.ExitNode == true)] | first | .HostName // empty' <<<"$status")
      if [[ "$state" != "Running" ]]; then
        alt="disconnected"
        text="vpn"
      elif [[ -n "$exit_node" ]]; then
        alt="exit"
        text="$exit_node"
      else
        alt="connected"
        text="vpn"
      fi
      ${pkgs.jq}/bin/jq -cn --arg text "$text" --arg alt "$alt" '{text: $text, alt: $alt}'
      sleep 5
    done
  '';
  tailscaleMenuScript = pkgs.writeShellScriptBin "tailscale-menu.sh" ''
    if ! ${tailscaledActive}; then
      ${pkgs.libnotify}/bin/notify-send "Tailscale" "tailscaled.service is not running"
      exit 0
    fi

    status=$(${tailscaleBin} status --json)
    state=$(${pkgs.jq}/bin/jq -r '.BackendState // "Stopped"' <<<"$status")

    if [[ "$state" != "Running" ]]; then
      selection=$(printf "Connect" | ${pkgs.fuzzel}/bin/fuzzel -d --prompt="Tailscale: ")
      [[ "$selection" == "Connect" ]] && ${tailscaleRoot} up && ${pkgs.libnotify}/bin/notify-send "Tailscale" "Connected"
      exit 0
    fi

    peers=$(${pkgs.jq}/bin/jq -r '.Peer[]? | select(.ExitNodeOption == true) | (if .ExitNode then "* " else "  " end) + .HostName + (if .Online then "" else " (offline)" end) + " [" + .TailscaleIPs[0] + "]"' <<<"$status" | sort)
    selection=$(printf 'Disconnect\nExit node: none\n%s\n' "$peers" | grep -v '^$' | ${pkgs.fuzzel}/bin/fuzzel -d --prompt="Tailscale: ")
    [[ -z "$selection" ]] && exit 0

    case "$selection" in
      "Disconnect")
        ${tailscaleRoot} down && ${pkgs.libnotify}/bin/notify-send "Tailscale" "Disconnected"
        ;;
      "Exit node: none")
        ${tailscaleRoot} set --exit-node= && ${pkgs.libnotify}/bin/notify-send "Tailscale" "Exit node cleared"
        ;;
      *)
        node_ip=$(sed -n 's/.*\[\(.*\)\]$/\1/p' <<<"$selection")
        node=$(sed 's/^[* ] //' <<<"$selection" | cut -d' ' -f1)
        if output=$(${tailscaleRoot} set --exit-node "$node_ip" 2>&1); then
          ${pkgs.libnotify}/bin/notify-send "Tailscale" "Exit node: $node"
        else
          ${pkgs.libnotify}/bin/notify-send "Tailscale" "Failed to set exit node $node (exit $?): $output"
        fi
        ;;
    esac
  '';
in {
  options.heywoodlh.hyprland = mkOption {
    default = false;
    description = ''
      Enable heywoodlh hyprland configuration.
    '';
    type = types.bool;
  };

  config = mkIf cfg {
    nix.settings = {
      sandbox = true;
      substituters = [
        "https://hyprland.cachix.org"
      ];
      trusted-public-keys = [
        "hyprland.cachix.org-1:a7pgxzMz7+chwVL3/pzj6jIBMioiJM7ypFP8PwtkuGc="
      ];
    };

    # Enable hyprland
    programs.hyprland = {
      enable = true;
      xwayland.enable = true;
      withUWSM = false;
    };
    programs.uwsm.enable = false;
    hardware.brillo.enable = true;
    environment.sessionVariables.WLR_NO_HARDWARE_CURSORS = "1";

    security.pam.services.hyprlock.fprintAuth = false;

    home-manager.users.${username} = {
      heywoodlh.home.hyprland = true;
      wayland.windowManager.hyprland = {
        extraConfig = ''
          hl.env("NIXOS_OZONE_WL", "1")
        '';
        systemd.enable = false;
      };
      programs.ashell.settings = lib.optionalAttrs config.services.tailscale.enable {
        modules.right = lib.mkBefore [ [ "Tailscale" ] ];
        CustomModule = [
          {
            name = "Tailscale";
            icon = builtins.fromJSON ''""'';
            command = "${tailscaleMenuScript}/bin/tailscale-menu.sh";
            listen_cmd = "${tailscaleStatusScript}/bin/tailscale-status.sh";
            icons = {
              "^disconnected$" = builtins.fromJSON ''""'';
              "^connected$" = builtins.fromJSON ''""'';
              "^exit$" = builtins.fromJSON ''""'';
              "^inactive$" = "";
            };
          }
        ];
      };
      # support fingerprint
      programs.hyprlock.settings = lib.optionalAttrs (config.services.fprintd.enable) {
        auth = {
          "fingerprint:enabled" = true;
        };
      };
    };
  };
}
