{ pkgs, config, lib, determinate-nix, ... }:

with lib;
with lib.types;

let
  cfg = config.heywoodlh.darwin.determinate;
  system = pkgs.stdenv.hostPlatform.system;
  nixPkg = determinate-nix.packages.${system}.default;
in {
  options.heywoodlh.darwin.determinate = {
    enable = mkOption {
      default = false;
      description = ''
        Enable heywoodlh Determinate Nix configuration.
      '';
      type = bool;
    };
    trustedUsers = mkOption {
      default = [
        "heywoodlh"
      ];
      description = ''
        Trusted Determinate Nix users.
      '';
      type = listOf singleLineStr;
    };
  };

  config = mkIf cfg.enable {
    nix.enable = false;
    environment.systemPackages = [
      nixPkg
    ];
    determinateNix = {
      enable = true;
      customSettings.extra-experimental-features = "external-builders";
      determinateNixd.builder.state = mkForce "enabled";
      nixosVmBasedLinuxBuilder = {
        enable = true;
        hostName = "nixos-vm-builder";
        systems = [
          "aarch64-linux"
          "x86_64-linux"
        ];
      };
      customSettings.trusted-users = cfg.trustedUsers;
    };
    system.activationScripts.chownLinuxBuilderKey = {
      enable = true;
      text = ''
        chown 501 /etc/nix/builder_ed25519 || true
      '';
    };
    system.activationScripts.nixosConfSymlink = {
      enable = true;
      text = ''
        test -e /etc/nix/nix.conf || ln -s /etc/nix/nix.custom.conf /etc/nix/nix.conf
      '';
    };
  };
}
