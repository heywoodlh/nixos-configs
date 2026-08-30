{ config, pkgs, lib, myFlakes, ssh-keys, nixpkgs-stable, ... }:

with lib;

let
  cfg = config.heywoodlh.sshd;
  system = stdenv.hostPlatform.system;
  stdenv = pkgs.stdenv;
  username = config.heywoodlh.defaults.user.name;
  myTmux = myFlakes.packages.${system}.tmux;
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
  };

  config = mkIf cfg.enable {
    services.openssh = {
      enable = true;
      # services.openssh.settings does not exist in darwin
      extraConfig = ''
        PermitRootLogin prohibit-password
        PasswordAuthentication no
        AcceptEnv TMUX_STATUS TMUX_SESSION
      '';
    };
    environment.systemPackages = with stable-pkgs; [
      mosh
      tmux
    ];

    users.users = {
      ${username} = {
        openssh.authorizedKeys.keyFiles = [ ssh-keys.outPath ];
      };
      root = {
        openssh.authorizedKeys.keyFiles = [ ssh-keys.outPath ];
      };
    };

    # Only start tmux if logging in as primary user -- don't make assumptions for other users
    home-manager.users.${username} = let
      tmuxInit = ''
        [ -z "''$TMUX" ] && { session_name=main; [ -n "''$TMUX_SESSION" ] && session_name="''$TMUX_SESSION"; ${myTmux}/bin/tmux new-session -A -s "''$session_name" && { [ -n "''$TMUX_STATUS" ] && ${myTmux}/bin/tmux set status on; exit; };}
      '';
    in {
      home.file.".zshenv".text = lib.optionalString (stdenv.hostPlatform.isDarwin) ''
        if [[ ''${SSH_TTY} ]]
        then
          ${tmuxInit}
        fi
      '';
      programs.bash = lib.optionalAttrs (stdenv.hostPlatform.isLinux) {
        enable = true;
        initExtra = tmuxInit;
      };
    };
  };
}
