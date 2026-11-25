{lib, ...}: {
  imports = [
    ../linux.nix
    ../linux/no-desktop.nix
  ];

  home = {
    username = "heywoodlh";
    homeDirectory = "/home/heywoodlh";
    stateVersion = "25.05";
  };

  programs.starship.enable = lib.mkForce false;
}
