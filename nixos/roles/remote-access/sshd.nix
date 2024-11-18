{ config, pkgs, nixpkgs-stable, ssh-keys, myFlakes, ... }:

let
  system = pkgs.system;
  stable-pkgs = import nixpkgs-stable {
    inherit system;
    config.allowUnfree = true;
  };
  tmux = myFlakes.packages.${system}.tmux;
in {
  networking.firewall = {
    enable = true;
    allowedTCPPorts = [ 22 ];
    # For Mosh
    allowedUDPPortRanges = [
      { from = 60000; to = 61000; }
    ];
  };

  # Duo for MFA
  security.duosec = {
    pam.enable = true;
    ssh.enable = true;
    host = "api-cb5d3f60.duosecurity.com";
    autopush = true;
    secretKeyFile = "/root/duo.key";
    integrationKey = "DI677924DNVV70FMD1DA";
  };

  services.openssh = {
    enable = true;
    settings.PermitRootLogin = "prohibit-password";
    settings.PasswordAuthentication = false;
    extraConfig = pkgs.lib.optionalString config.security.duosec.ssh.enable ''
      ForceCommand /usr/bin/env login_duo
    '';
  };

  environment.systemPackages = with stable-pkgs; [
    mosh
  ];

  users.users.heywoodlh = {
    openssh.authorizedKeys.keyFiles = [ ssh-keys.outPath ];
  };
  users.users.root = {
    openssh.authorizedKeys.keys = [
      "from=\"100.126.114.23\" ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQCqdFcgb5hjpk09z4y7YW8ocSghB7QuuX71izgwSQgcBam2TYi+wsFYpnx+IJmRNp3470jjib/qUZkOICrpjLMiFuveGeySp4ZxzNjIvr/GcTOewmmoAFiQm5JU/Z1Sm8ZtqbglhLJiuMP7ybdCGzKnmiNCyCEE2U39KA+6mH68eGBvYLa7MKuRiv2X0DC2WJoxPHW9nnzIhB7L6nokzs08LBox6j5CM2UoXoFAbb8/06iURzBPXp2uNn0S1VJ3QX7W3GV5vUNnmWriWukNb5+G1yNafRbr6WwvfL+n9wXH3gMavma/NRaPE9B9smjJJ5201v8YBOBFPjJ9w0iUr/mN/bsba5g83APTAD88obRqrkcFFCFxRSZZ6CxvUEN0om9O3GasU734xt1eReO5w4LYw84/j7SmNwsezG8c6/lLUnW7e0VqP7UQ+6Y7Db/HVZ8v9rRxMWI6IbVKYTS/LtTEvkcOvO7gJlBsa1gxUxyKDczP/O6Y4d2BLmXmbql5nvU= rsnapshot"
    ];
  };

  programs.bash.interactiveShellInit = ''
    [ -z $TMUX ] && { ${tmux}/bin/tmux new-session \; send-keys "tmux Space set Space -g Space status Space off Space && Space clear" C-m && exit;}
  '';

  # Start ssh-agent manually if on ssh
  home-manager.users.heywoodlh.home.file.".config/fish/machine.fish" = {
    text = ''
      test -n $SSH_CONNECTION && eval (ssh-agent -c) &> /dev/null
    '';
  };
}
