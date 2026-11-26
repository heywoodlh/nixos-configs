{
  pkgs,
  myPkgs,
  ...
}: let
  starship_config = pkgs.writeText "starship.toml" ''
    [character]
    success_symbol = ' [❯](bold white)'
    error_symbol = ' [❯](bold red)'

    [container]
    disabled = true
  '';
in {
  imports = [
    ../linux.nix
    ../linux/no-desktop.nix
  ];

  home = {
    username = "heywoodlh";
    homeDirectory = "/home/heywoodlh.guest";
    stateVersion = "25.05";
  };

  programs.bash = {
    enable = true;
    initExtra = ''
      [ -z $TMUX ] && { ${myPkgs.tmux}/bin/tmux new-session -A -s main && exit;}
    '';
  };

  home.file.".config/fish/config.fish".text = ''
    # Custom Starship prompt to remind me I'm in a VM
    set -gx STARSHIP_CONFIG "${starship_config}"
    ${pkgs.starship}/bin/starship init fish | source
  '';
}
