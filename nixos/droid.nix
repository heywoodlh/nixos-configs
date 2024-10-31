{ config, pkgs, nix-on-droid, myFlakes, ssh-keys, ... }:

let
  sshdTmpDirectory = "${config.user.home}/sshd-tmp";
  sshdDirectory = "${config.user.home}/sshd";
  pathToPubKey = ssh-keys.outPath;
  port = 8022;
  system = pkgs.system;
  myVim = myFlakes.packages.${system}.vim;
  myZellij = myFlakes.packages.${system}.zellij;
  myGit = myFlakes.packages.${system}.git;
in
{
  imports = [
    ./base.nix
  ];
  user.shell = "${myZellij}/bin/zellij";
  nix.extraOptions = ''
    experimental-features = nix-command flakes
  '';

  build.activation.sshd = ''
    $DRY_RUN_CMD mkdir $VERBOSE_ARG --parents "${config.user.home}/.ssh"
    $DRY_RUN_CMD cat ${pathToPubKey} > "${config.user.home}/.ssh/authorized_keys"

    if [[ ! -d "${sshdDirectory}" ]]; then
      $DRY_RUN_CMD rm $VERBOSE_ARG --recursive --force "${sshdTmpDirectory}"
      $DRY_RUN_CMD mkdir $VERBOSE_ARG --parents "${sshdTmpDirectory}"

      $VERBOSE_ECHO "Generating host keys..."
      $DRY_RUN_CMD ${pkgs.openssh}/bin/ssh-keygen -t rsa -b 4096 -f "${sshdTmpDirectory}/ssh_host_rsa_key" -N ""

      $VERBOSE_ECHO "Writing sshd_config..."
      $DRY_RUN_CMD echo -e "HostKey ${sshdDirectory}/ssh_host_rsa_key\nPort ${toString port}\n" > "${sshdTmpDirectory}/sshd_config"

      $DRY_RUN_CMD mv $VERBOSE_ARG "${sshdTmpDirectory}" "${sshdDirectory}"
    fi
  '';

  environment.packages = [
    (pkgs.writeScriptBin "sshd-start" ''
      #!${pkgs.runtimeShell}

      echo "Starting sshd in non-daemonized way on port ${toString port}"
      ${pkgs.openssh}/bin/sshd -f "${sshdDirectory}/sshd_config" -D
    '')
    myGit
    myVim
    pkgs.busybox
    pkgs.coreutils
  ];

  home-manager = {
    config = ./roles/droid/home.nix;
    backupFileExtension = "hm-bak";
  };
}
