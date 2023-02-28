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

  system.activationScripts.postActivate = ''
    /run/wrappers/bin/su ${username} -c "bash -c '
      # Check if the clone directory exists, otherwise clone the repository
      [[ -d ${cloneDir} ]] || git clone https://github.com/${username}/conf ${cloneDir}

      # Change directory to the clone directory and run the appropriate commands
      cd ${cloneDir} \
      && peru sync \
      && pwsh -executionpolicy bypass -file ./setup.ps1
    '"
  '';
}
