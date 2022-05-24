{ config, pkgs, ... }:

{
  nix.trustedUsers = [
    "@admin"
  ];

  # Install and setup ZSH to work with nix(-darwin) as well
  programs.zsh.enable = true;
  environment.variables.SHELL = "${pkgs.zsh}/bin/zsh";
}
