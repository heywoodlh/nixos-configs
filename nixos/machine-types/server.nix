{
  lib,
  nixConfig,
  ...
}: {
  imports = [
    ../roles/nixos/daily-flake-switch.nix
    ../roles/security/sshd-monitor.nix
    ../roles/tailscale.nix
    ../roles/monitoring/syslog-ng/client.nix
    ../roles/monitoring/node-exporter.nix
  ];

  heywoodlh = {
    server = true;
    nixos.scrutiny = {
      enable = true;
      port = 3050;
      ntfy = "ntfy://ntfy.barn-banana.ts.net/monitoring";
    };
  };

  nix.settings = lib.mkMerge [
    {auto-optimise-store = true;}
    nixConfig
  ];

  home-manager.sharedModules = [../../home/linux/no-desktop.nix];
}
