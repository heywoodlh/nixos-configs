{ config, pkgs, ... }:

{
  networking.firewall.interfaces.tailscale0.allowedTCPPorts = [ 5000 ];
  services.nix-serve = {
    enable = true;
    secretKeyFile = "/var/cache-priv-key.pem";
  };

  systemd.timers."nix-cache-build" = {
    wantedBy = [ "timers.target" ];
      timerConfig = {
        OnCalendar = "weekly";
        Unit = "nix-cache-build.service";
      };
  };
  systemd.services."nix-cache-build" = {
    script = ''
      set -eu
      export NIXPKGS_ALLOW_UNFREE=1
      # nixos-configs build
      rm -rf /tmp/nixos-configs
      ${pkgs.git}/bin/git clone https://github.com/heywoodlh/nixos-configs.git /tmp/nixos-configs
      ${pkgs.nixos-rebuild}/bin/nixos-rebuild build --flake /tmp/nixos-configs#nixos-server-intel --impure
      ${pkgs.nixos-rebuild}/bin/nixos-rebuild build --flake /tmp/nixos-configs#nixos-desktop-intel --impure

      rm -rf /tmp/nixos-configs
    '';
    serviceConfig = {
      Type = "oneshot";
      User = "root";
    };
  };
}
