{
  description = "nixops configurations";
  inputs = {
    deploy-rs.url = "github:serokell/deploy-rs";
    nixos-configs.url = "github:heywoodlh/nixos-configs/master";
  };

  outputs = { self, nixpkgs, deploy-rs, nixos-configs }:
  let
    nixos-systems = nixos-configs.packages.x86_64-linux.nixosConfigurations;
  in {
    deploy.nodes = {
      nix-tools = {
        hostname = "nix-tools.tailscale";
        sshUser = "heywoodlh";
        user = "root";
        profiles.system = {
          path = deploy-rs.lib.x86_64-linux.activate.nixos nixos-systems.nix-tools;
        };
      };
      nix-backups = {
        hostname = "nix-backups.tailscale";
        sshUser = "heywoodlh";
        user = "root";
        profiles.system = {
          path = deploy-rs.lib.x86_64-linux.activate.nixos nixos-systems.nix-backups;
        };
      };
      nix-precision = {
        hostname = "nix-precision.tailscale";
        sshUser = "heywoodlh";
        user = "root";
        profiles.system = {
          path = deploy-rs.lib.x86_64-linux.activate.nixos nixos-systems.nix-precision;
        };
      };
      nix-ext-net = {
        hostname = "nix-ext-net.tailscale";
        sshUser = "heywoodlh";
        user = "root";
        profiles.system = {
          path = deploy-rs.lib.x86_64-linux.activate.nixos nixos-systems.nix-ext-net;
        };
      };
      nix-media = {
        hostname = "nix-media.tailscale";
        sshUser = "heywoodlh";
        user = "root";
        profiles.system = {
          path = deploy-rs.lib.x86_64-linux.activate.nixos nixos-systems.nix-media;
        };
      };
      nix-drive = {
        hostname = "nix-drive.tailscale";
        sshUser = "heywoodlh";
        user = "root";
        profiles.system = {
          path = deploy-rs.lib.x86_64-linux.activate.nixos nixos-systems.nix-drive;
        };
      };
    };
    checks = builtins.mapAttrs (system: deployLib: deployLib.deployChecks self.deploy) deploy-rs.lib;
  };
}
