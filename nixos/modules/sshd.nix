{ config, pkgs, lib, ... }:

with lib;

let
  cfg = config.heywoodlh.sshd;
in {
  options.heywoodlh.sshd = {
    mfa = mkOption {
      default = false;
      description = ''
        Require an SSH key and Duo approval.
      '';
      type = types.bool;
    };
    duo = mkOption {
      default = false;
      description = ''
        Allow Duo approval when an SSH key is unavailable.
      '';
      type = types.bool;
    };
    tailscale = mkOption {
      default = false;
      description = ''
        Restrict SSH to Tailscale.
      '';
      type = types.bool;
    };
  };

  config = mkIf cfg.enable (mkMerge [
    (mkIf cfg.mfa {
      heywoodlh.sshd.duo = mkForce true;
    })
    {
    heywoodlh.defaults.enable = true;
    networking.firewall = {
      enable = true;
      allowedTCPPorts = lib.optionals (cfg.tailscale == false) [ 22 ];
      # For Mosh
      allowedUDPPortRanges = lib.optionals (cfg.tailscale == false) [
        { from = 60000; to = 61000; }
      ];
      # Always allow on Tailscale
      interfaces.tailscale0 = {
        allowedTCPPorts = [
          22
        ];
        allowedUDPPortRanges = [
          { from = 60000; to = 61000; }
        ];
      };
    };

    security.duosec = {
      pam.enable = cfg.duo;
      ssh.enable = cfg.duo;
      host = "api-cb5d3f60.duosecurity.com";
      failmode = "secure";
      autopush = true;
      prompts = 1;
      secretKeyFile = "/root/duo.key";
      integrationKey = "DI677924DNVV70FMD1DA";
    };

    services.openssh.settings = {
      AuthenticationMethods =
        if cfg.mfa then "publickey,keyboard-interactive"
        else if cfg.duo then "publickey keyboard-interactive"
        else "publickey";
      UsePAM = cfg.duo;
    };

    security.pam.services.sshd.text = lib.optionalString cfg.duo ''
      account required pam_unix.so

      auth required ${pkgs.duo-unix}/lib/security/pam_duo.so
      auth sufficient pam_permit.so

      session required pam_env.so conffile=/etc/pam/environment readenv=0
      session required pam_unix.so
      session required pam_loginuid.so
      session optional ${pkgs.systemd}/lib/security/pam_systemd.so
    '';
    }
  ]);
}
