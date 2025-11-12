{ config, pkgs, ... }:

let
  tarsnapSetup = pkgs.writeShellScriptBin "tarsnap-setup.sh" ''
    sudo ${pkgs.tarsnap}/bin/tarsnap-keygen \
      --keyfile /root/tarsnap.key \
      --user tarsnap@heywoodlh.io \
      --machine $(hostname)
  '';
  tarsnapList = pkgs.writeShellScriptBin "tarsnap-list-archives.sh" ''
    sudo ${pkgs.tarsnap}/bin/tarsnap --list-archives --keyfile /root/tarsnap.key --cachedir /var/cache/tarsnap/nixos-archive
  '';
  tarsnapRun = pkgs.writeShellScriptBin "tarsnap-run.sh" ''
    # General tarsnap options as arguments
    sudo ${pkgs.tarsnap}/bin/tarsnap $@ --configfile "/etc/tarsnap/nixos.conf" -c -f "nixos-$(date +"%Y%m%d%H%M%S")" /etc /opt /root /home
  '';
  tarsnapDryRun = pkgs.writeShellScriptBin "tarsnap-dry-run.sh" ''
    ${tarsnapRun}/bin/tarsnap-run.sh --dry-run
  '';
  tarsnapDeleteArchives = pkgs.writeShellScriptBin "tarsnap-delete-archives.sh" ''
    backups="$(${tarsnapList}/bin/tarsnap-list-archives.sh)"

    read -p "Are you sure you want to delete all Tarsnap arhives (yY)? " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]
    then
        for backup in ''${backups}
        do
          echo "Backup: ''${backup}"
          sudo ${pkgs.tarsnap}/bin/tarsnap -d --keyfile /root/tarsnap.key --cachedir /var/cache/tarsnap/nixos-archive -f "''${backup}" && echo "Backup ''${backup} deleted"
        done
    fi
  '';
in {
  environment.systemPackages = with pkgs; [
    tarsnap
    tarsnapList
    tarsnapSetup
    tarsnapDryRun
    tarsnapRun
    tarsnapDeleteArchives
  ];
  services.tarsnap = {
    enable = true;
    package = pkgs.tarsnap;
    keyfile = "/root/tarsnap.key";
    archives = {
      nixos =  {
        cachedir = "/var/cache/tarsnap/nixos-archive";
        directories = [
          "/etc"
          "/opt"
          "/root"
          "/home"
        ];
        excludes = [
          "tarsnap.key"
          "shadow"
          "passwd"
          "nixpkgs"
          "containerd"
          ".cache"
          ".lima"
          ".local"
          "anomaly"
          "gamma"
        ];
      };
    };
  };
}
