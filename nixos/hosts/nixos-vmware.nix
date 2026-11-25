{...}: {
  imports = [/etc/nixos/hardware-configuration.nix];

  virtualisation.vmware.guest.enable = true;
  console.earlySetup = true;

  fileSystems."/shared" = {
    device = ".host:/";
    fsType = "fuse./run/current-system/sw/bin/vmhgfs-fuse";
    options = [
      "allow_other"
      "auto_unmount"
      "defaults"
      "gid=1000"
      "uid=1000"
      "umask=0022"
    ];
  };

  home-manager.users.heywoodlh.home.file.".gitconfig".text = ''
    [safe]
    directory = "/shared/*";
  '';
}
