{
  nixpkgs,
  pkgs,
  ssh-keys,
  ...
}: {
  imports = [
    (nixpkgs + "/nixos/modules/installer/cd-dvd/installation-cd-graphical-gnome.nix")
    ../roles/nixos/attic.nix
  ];

  programs.neovim = {
    enable = true;
    vimAlias = true;
    viAlias = true;
  };

  environment.systemPackages = with pkgs; [
    calamares-nixos
    calamares-nixos-extensions
    disko
    git
    helix
    msedit
    nano
    nixos-install
    e2fsprogs
  ];

  services.tailscale.enable = true;
  services.openssh.enable = true;
  users.users.nixos.openssh.authorizedKeys.keyFiles = [ssh-keys];
  nix.settings.experimental-features = ["nix-command" "flakes"];
}
