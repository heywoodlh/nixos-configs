{ config, pkgs, ... }:

let
  chown_script = pkgs.writeShellScriptBin "chown-rsnapshot" ''
    #!/usr/bin/env bash
    chown -R root:backups /media/backups/
    chmod -R g+r /media/backups
  '';
in {
  # Create backup user and group
  users = {
    groups = {
      backups = {};
    };
    users.backups = {
      createHome = true;
      isNormalUser = true;
      description = "backups";
      group = "backups";
      home = "/home/backups";
      shell = "${pkgs.bash}/bin/bash";
      openssh.authorizedKeys.keys = [
        "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAAAgQDfGoaMlrNGuu3kPeq3spOKN8d8orcMKdnEHccSaZQOZ09UdOQVTd6xxpNUvghsvl5QidcZVW6Rftql3D2y3dwjnZ5JO4m+u+15RLRsh43duUO/S+uDzhgcQ/JxAnqUFbJwV/JRUCrKMzhlecAZIrN49lpceTkWhqKalfEz/04+mQ== nix-drive"
      ];
    };
  };

  services.openssh.settings.Macs = [
   "hmac-sha2-512-etm@openssh.com"
   "hmac-sha2-256-etm@openssh.com"
   "umac-128-etm@openssh.com"
   "hmac-sha2-256"
   "hmac-sha1-96"
   "hmac-sha1"
   "hmac-md5-96"
   "hmac-md5"
  ];

  services.rsnapshot = {
    enable = true;
    enableManualRsnapshot = true;
    cronIntervals = {
      hourly = "0 * * * *";
      daily = "30 5 * * *";
      weekly = "0 8 * * 1";
      monthly = "0 13 1 * *";
    };
    extraConfig = ''
#Separate everything with tabs, not spaces
#Convert spaces to tabs in vim with :%s/\s\+/\t/g
logfile	/media/backups/log/rsnapshot.log
snapshot_root	/media/backups/
retain	hourly	24
retain	daily	7
retain	weekly	4
retain	monthly	6

backup	root@nixos-matrix.tailscale:/etc/	nixos-matrix/	exclude=/etc/shadow,exclude=/etc/passwd
backup	root@nixos-matrix.tailscale:/home/	nixos-matrix/
backup	root@nixos-matrix.tailscale:/opt/	nixos-matrix/
backup	root@nixos-matrix.tailscale:/root/	nixos-matrix/

backup	root@nix-precision.tailscale:/etc/	nix-precision/	exclude=/etc/shadow,exclude=/etc/passwd
backup	root@nix-precision.tailscale:/home/	nix-precision/
backup	root@nix-precision.tailscale:/opt/	nix-precision/
backup	root@nix-precision.tailscale:/root/	nix-precision/

backup	root@nix-nvidia.tailscale:/etc/	nix-nvidia/	exclude=/etc/shadow,exclude=/etc/passwd
backup	root@nix-nvidia.tailscale:/home/	nix-nvidia/
backup	root@nix-nvidia.tailscale:/opt/	nix-nvidia/
backup	root@nix-nvidia.tailscale:/root/	nix-nvidia/

backup	root@nix-drive.tailscale:/etc/	nix-drive/	exclude=/etc/shadow,exclude=/etc/passwd
backup	root@nix-drive.tailscale:/home/	nix-drive/
backup	root@nix-drive.tailscale:/opt/	nix-drive/
backup	root@nix-drive.tailscale:/root/	nix-drive/

cmd_postexec	${chown_script}/bin/chown-rsnapshot
    '';
  };
}
