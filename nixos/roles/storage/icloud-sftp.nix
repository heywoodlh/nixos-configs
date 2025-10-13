{ pkgs, config, ... }:

# Prep with these commands:
# ```
# sudo -E ssh-keygen -f /root/.ssh/mac-mini
# sudo -E ssh-copy-id -i /root/.ssh/mac-mini.pub heywoodlh@mac-mini
# ```
{
  programs.fuse.userAllowOther = true;
  fileSystems."/mnt/icloud" = {
    device = "heywoodlh@mac-mini.barn-banana.ts.net:/Users/heywoodlh/Library/Mobile Documents/com~apple~CloudDocs";
    fsType = "sshfs";
    options = [
      "reconnect"
      "ServerAliveInterval=15"
      "ServerAliveCountMax=3"
      "nodev"
      "noatime"
      "allow_other"
      "uid=1000"
      "follow_symlinks"
      "IdentityFile=/root/.ssh/mac-mini"
    ];
  };
  system.activationScripts.iCloudSymlink.text = ''
    mkdir -p /home/heywoodlh/mnt
    test -L /home/heywoodlh/mnt/icloud || ln -sf /mnt/icloud /home/heywoodlh/mnt/icloud
    test -L /home/heywoodlh/mnt/icloud-drive || ln -sf /mnt/icloud /home/heywoodlh/mnt/icloud-drive
    chown -R heywoodlh /home/heywoodlh/mnt
  '';
}
