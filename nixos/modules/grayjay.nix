{ config, lib, ... }:

with lib;
with lib.types;

let
  cfg = config.heywoodlh.nixos.grayjay;
in {
  options.heywoodlh.nixos.grayjay = {
    enable = mkOption {
      default = false;
      description = "Enable Grayjay container.";
      type = bool;
    };
    tailscale = mkOption {
      default = true;
      description = "Enable Grayjay container for use over Tailscale.";
      type = bool;
    };
    volume = mkOption {
      default = "grayjay";
      description = "Volume to use for Grayjay.";
      type = str;
    };
  };

  config = mkIf cfg.enable {
    virtualisation.oci-containers.containers.grayjay = {
      image = "docker.io/heywoodlh/nix:2.33.3";
      entrypoint = "nix";
      cmd = [
        "--extra-experimental-features"
        "'nix-command flakes'"
        "run"
        "--impure"
        "github:nixos/nixpkgs/nixos-25.11#grayjay"
        "--"
        "--server"
        "--ignore-security"
      ];
      environment = {
        NIXPKGS_ALLOW_UNFREE = "1";
        DOTNET_SYSTEM_GLOBALIZATION_INVARIANT = "1";
        ASPNETCORE_URLS = "http://0.0.0.0:11338";
        GRAYJAY_HTTP_PROXY_PORT = "11339";
        GRAYJAY_CASTING_PORT = "11340";
        XDG_DATA_HOME = "/home/nix/grayjay";
      };
      ports = [
        "11338:11338"
        "11339:11339"
        "11340:11340"
      ];
      volumes = [
        "${cfg.volume}:/home/nix/grayjay"
      ];
    };

    networking.firewall.interfaces.tailscale0.allowedTCPPorts = lib.optionals (cfg.tailscale) [
      11338
      11339
      11340
    ];

    networking.firewall.allowedTCPPorts = lib.optionals (cfg.tailscale != true) [
      11338
      11339
      11340
    ];
  };
}
