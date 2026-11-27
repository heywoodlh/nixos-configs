{
  pkgs,
  ssh-keys,
  ...
}: {
  imports = [
    ../roles/nixos/attic.nix
    /etc/nixos/hardware-configuration.nix
    /etc/nixos/configuration.nix
  ];

  services.openssh.enable = true;
  services.tailscale.enable = true;

  services.syncthing = {
    enable = true;
    user = "heywoodlh";
    dataDir = "/home/heywoodlh/Sync";
    configDir = "/home/heywoodlh/.config/syncthing";
  };

  users.users = {
    heywoodlh.openssh.authorizedKeys.keyFiles = [ssh-keys.outPath];
    root.openssh.authorizedKeys.keyFiles = [ssh-keys.outPath];
  };

  programs.neovim = {
    enable = true;
    vimAlias = true;
    viAlias = true;
  };

  environment.systemPackages = with pkgs; [
    git
    helix
    msedit
    nano
  ];
}
