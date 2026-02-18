{ config, pkgs, lib, myFlakes, ssh-keys, nixpkgs-stable, ... }:

with lib;

let
  cfg = config.heywoodlh.sshd;
  system = pkgs.stdenv.hostPlatform.system;
  username = config.heywoodlh.defaults.user.name;
  tmux = myFlakes.packages.${system}.tmux;
  stable-pkgs = import nixpkgs-stable {
    inherit system;
    config.allowUnfree = true;
  };
in {
  options.heywoodlh.sshd = {
    enable = mkOption {
      default = false;
      description = ''
        Enable heywoodlh ssh configuration.
      '';
      type = types.bool;
    };
    mfa = mkOption {
      default = false;
      description = ''
        Enable mfa configuration for SSH.
      '';
      type = types.bool;
    };
  };

  config = mkIf cfg.enable {
    heywoodlh.defaults.enable = true;
    networking.firewall = {
      enable = true;
      allowedTCPPorts = [ 22 ];
      # For Mosh
      allowedUDPPortRanges = [
        { from = 60000; to = 61000; }
      ];
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
      enable = true;
      settings = {
        PermitRootLogin = "prohibit-password";
        PasswordAuthentication = false;
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

    environment.systemPackages = with stable-pkgs; [
      mosh
      tmux
    ] ++ lib.optionals (cfg.mfa) [
      google-authenticator
    ];

    users.users.${username} = {
      openssh.authorizedKeys.keyFiles = [ ssh-keys.outPath ];
    };
    users.users.root = {
      openssh.authorizedKeys.keys = [
        "from=\"100.126.114.23\" ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQCqdFcgb5hjpk09z4y7YW8ocSghB7QuuX71izgwSQgcBam2TYi+wsFYpnx+IJmRNp3470jjib/qUZkOICrpjLMiFuveGeySp4ZxzNjIvr/GcTOewmmoAFiQm5JU/Z1Sm8ZtqbglhLJiuMP7ybdCGzKnmiNCyCEE2U39KA+6mH68eGBvYLa7MKuRiv2X0DC2WJoxPHW9nnzIhB7L6nokzs08LBox6j5CM2UoXoFAbb8/06iURzBPXp2uNn0S1VJ3QX7W3GV5vUNnmWriWukNb5+G1yNafRbr6WwvfL+n9wXH3gMavma/NRaPE9B9smjJJ5201v8YBOBFPjJ9w0iUr/mN/bsba5g83APTAD88obRqrkcFFCFxRSZZ6CxvUEN0om9O3GasU734xt1eReO5w4LYw84/j7SmNwsezG8c6/lLUnW7e0VqP7UQ+6Y7Db/HVZ8v9rRxMWI6IbVKYTS/LtTEvkcOvO7gJlBsa1gxUxyKDczP/O6Y4d2BLmXmbql5nvU= rsnapshot"
      ];
    };

    programs.bash.interactiveShellInit = ''
      [ -z $TMUX ] && { ${tmux}/bin/tmux new-session -A -s main && exit;}
    '';

    boot.postBootCommands = optionalString (cfg.mfa) ''
      test -e /root/.google_authenticator || ln -s /root/.google_authenticator ~${username}/.google_authenticator
    '';
  };
}
