{ config, pkgs, ssh-keys, myFlakes, ... }:

let
  system = pkgs.system;
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

  services.openssh = {
    enable = true;
    sftpServerExecutable = "internal-sftp";
    settings.PermitRootLogin = "prohibit-password";
    settings.PasswordAuthentication = false;
  };

  environment.systemPackages = with pkgs; [
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
    [ -z $TMUX ] && { ${tmux}/bin/tmux && exit;}
  '';
}
