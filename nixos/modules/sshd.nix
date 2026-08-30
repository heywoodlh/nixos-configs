{ config, pkgs, lib, ... }:

with lib;

let
  cfg = config.heywoodlh.sshd;
  username = config.heywoodlh.defaults.user.name;
in {
  options.heywoodlh.sshd = {
    mfa = mkOption {
      default = false;
      description = ''
        Enable mfa configuration for SSH.
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

  config = mkIf cfg.enable {
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

    # Duo for MFA, disabled in favor of google authenticator module
    # Keeping around in case I want to keep it
    security.duosec = {
      pam.enable = false;
      ssh.enable = false;
      host = "api-cb5d3f60.duosecurity.com";
      autopush = true;
      secretKeyFile = "/root/duo.key";
      integrationKey = "DI677924DNVV70FMD1DA";
    };

    services.openssh = {
      settings = {
        AuthenticationMethods = if (cfg.mfa) then "publickey,keyboard-interactive" else "publickey";
        UsePAM = cfg.mfa;
      };
      extraConfig = lib.optionalString (config.security.duosec.ssh.enable) ''
        ForceCommand /usr/bin/env login_duo
      '';
    };

    # Setup with (non-root): `google-authenticator`
    security.pam.services.sshd.googleAuthenticator = {
      enable = cfg.mfa;
      allowNullOTP = true; # Allow logins for unconfigured accounts
    };

    # https://github.com/NixOS/nixpkgs/issues/115044#issuecomment-2065409087
    # Get Google Auth working with SSH keys
    security.pam.services.sshd.text = lib.optionalString (cfg.mfa) ''
      account required pam_unix.so # unix (order 10900)

      auth required ${pkgs.google-authenticator}/lib/security/pam_google_authenticator.so nullok no_increment_hotp # google_authenticator (order 12500)
      auth sufficient pam_permit.so

      session required pam_env.so conffile=/etc/pam/environment readenv=0 # env (order 10100)
      session required pam_unix.so # unix (order 10200)
      session required pam_loginuid.so # loginuid (order 10300)
      session optional ${pkgs.systemd}/lib/security/pam_systemd.so # systemd (order 12000)
    '';

    environment.systemPackages = lib.optionals (cfg.mfa) [
      google-authenticator
    ];

    boot.postBootCommands = optionalString (cfg.mfa) ''
      test -e /root/.google_authenticator || ln -s /root/.google_authenticator ~${username}/.google_authenticator
    '';
  };
}
