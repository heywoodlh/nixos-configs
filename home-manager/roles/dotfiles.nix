{ config, pkgs, ... }:

let
  username = "heywoodlh";
  userHome = "/home/${username}";
  cloneDir = "${userHome}/opt/conf";
in {
  environment.systemPackages = with pkgs; [
    git
    powershell
    peru
  ];

  home.activationShell = ''
    ${pkgs.bash}/bin/bash -c '
      PATH=${pkgs.peru}/bin:${pkgs.git}/bin:${pkgs.powershell}/bin:${pkgs.bash}/bin:${pkgs.coreutils}/bin:$PATH
      # Check if the clone directory exists, otherwise clone the repository
      [[ -d ${cloneDir} ]] || ${pkgs.git}/bin/git clone https://github.com/${username}/conf ${cloneDir}

      # Change directory to the clone directory and run the appropriate commands
      cd ${cloneDir} \
      && ${pkgs.peru}/bin/peru sync \
      && ${pkgs.powershell}/bin/pwsh -executionpolicy bypass -file ./setup.ps1
    '
  '';
}
