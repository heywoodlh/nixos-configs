{pkgs, ...}: {
  imports = [
    ../linux.nix
    ../desktop.nix
    ../linux/desktop.nix
  ];

  home = {
    username = "heywoodlh";
    homeDirectory = "/home/heywoodlh";
    stateVersion = "25.05";
  };

  heywoodlh.home = {
    onepassword.enable = true;
    gnome = true;
  };

  home.packages = [pkgs.nerd-fonts.jetbrains-mono];

  home.file."bin/create-docker" = {
    enable = true;
    executable = true;
    text = ''
      #!/usr/bin/env bash
      ${pkgs.lima}/bin/limactl list | grep default | grep -q Running || ${pkgs.lima}/bin/limactl start --name=default template://docker
      ${pkgs.docker-client}/bin/docker context create lima-default --docker "host=unix:///Users/heywoodlh/.lima/default/sock/docker.sock"
      ${pkgs.docker-client}/bin/docker context use lima-default
    '';
  };
}
