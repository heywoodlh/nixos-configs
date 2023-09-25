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
        "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQCbD30q6xvJoS/pmXvqGQHCGF8HgifaLlHzIS3bMBTDT4pPC0oJyawgBUY2ZM8XCkXcwCDQQxOsAC7JYAUr0LCUwNvI4DJVlO9pBivpZoo5KhHQJEj3SvIkgnKAdoruBWgS9reuAznWQcRTAhsRZWwcgPuFASVqoPPr5rGQo+Ki0Za4/+pAXjgnREG6e/2KwYNoPYpb00ekE+VwHSh+xTb/PZYU46SDPOaxXr9hPB0ICfvBFlXPI32QAhbRTdYYTPkG19bYUp1NTuEJE6ys9BNn4HF4TYfWF1Jb7CdPkvPwmnIgAiw5HTSxOQH0JUhCzgNDPGsXgQt0McQpU41iFp0DJss0d2uWiBs6hWypptKSczgsyb10HRp7LWQkKJ0pWU4fW2NZl2aoSpX0p6L3e1XI9eqXGJxW9iJ8bfpog7Z8lS1oHGUbP5tdaOEzw/0CoI+mIBignZhyKhVmRL6ZgRnZbjwZgnVPtNkd2ly0uKT5T9ukiP1Rqafi+m4AQpHrKvGraZxTT1DLM8PPDV+gKv4J7jNb7zEiQxkdcA8e0MqptS+C40VM2zicv+kEZtm7KtFpCKaqcDYFy9kCrPtO2ORi5uCYG88QLwkcjW8uhD5pkK8ohBgnEoemKZl3QF8oOkpEHRzRjojHdfaRr4UbQqPmjYmxcCAQa78L8kr+hbEvXQ== nextcloud"
      ];
    };
  };

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

backup	root@nix-tools.tailscale:/etc/	nix-tools/	exclude=/etc/shadow,exclude=/etc/passwd
backup	root@nix-tools.tailscale:/home/	nix-tools/
backup	root@nix-tools.tailscale:/opt/	nix-tools/
backup	root@nix-tools.tailscale:/root/	nix-tools/

backup	root@nix-precision.tailscale:/etc/	nix-precision/	exclude=/etc/shadow,exclude=/etc/passwd
backup	root@nix-precision.tailscale:/home/	nix-precision/
backup	root@nix-precision.tailscale:/opt/	nix-precision/
backup	root@nix-precision.tailscale:/root/	nix-precision/

backup	root@nix-media.tailscale:/etc/	nix-media/	exclude=/etc/shadow,exclude=/etc/passwd
backup	root@nix-media.tailscale:/home/	nix-media/
backup	root@nix-media.tailscale:/opt/	nix-media/
backup	root@nix-media.tailscale:/root/	nix-media/
backup	root@nix-media.tailscale:/media/services/freshrss/	nix-media/
backup	root@nix-media.tailscale:/media/services/sabnzbd/	nix-media/
backup	root@nix-media.tailscale:/media/services/radarr/	nix-media/
backup	root@nix-media.tailscale:/media/services/sonarr/	nix-media/
backup	root@nix-media.tailscale:/media/services/tautulli/	nix-media/

backup	root@nix-ext-net.tailscale:/etc/	nix-ext-net/	exclude=/etc/shadow,exclude=/etc/passwd
backup	root@nix-ext-net.tailscale:/home/	nix-ext-net/
backup	root@nix-ext-net.tailscale:/opt/	nix-ext-net/
backup	root@nix-ext-net.tailscale:/root/	nix-ext-net/

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
