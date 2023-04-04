{ config, pkgs, ... }:

let
  nixos-switch-auto = pkgs.writeScriptBin "nixos-switch-auto" ''
    #!/usr/bin/env bash
    # This script automatically updates my flake locally

    [[ ! -d /opt/nixos-configs ]] && git clone https://github.com/heywoodlh/nixos-configs /opt/nixos-configs && export NIXOS_DOWNLOAD=1
    git -C /home/heywoodlh/opt/conf pull origin master || true

    # If NIXOS_DOWNLOAD = 1, then run nixos-rebuild switch
    if [[ $NIXOS_DOWNLOAD == 1 ]]
    then
        nixos-rebuild switch --flake /opt/nixos-configs#$(hostname) --impure && export AUTO_UPDATE=1
        if [[ $AUTO_UPDATE == 1 ]]
        then
            echo "Auto updated $(hostname) to $(nixos-version)" | gotify push -t "NixOS update: $(hostname)" 
        else
            echo "Failed to auto update $(hostname)" | gotify push -t "NixOS update failed: $(hostname)"
        fi 
    fi

    # If /opt/nixos-configs is out of date, then run git pull
    if git -C /opt/nixos-configs remote show origin  | grep -iq "out of date"
    then
        git -C /opt/nixos-configs pull origin master
        nixos-rebuild switch --flake /opt/nixos-configs#$(hostname) --impure && export AUTO_UPDATE=1

        if [[ $AUTO_UPDATE == 1 ]]
        then
            echo "Auto updated $(hostname) to $(nixos-version)" | gotify push -t "NixOS update: $(hostname)" 
        else
            echo "Failed to auto update $(hostname)" | gotify push -t "NixOS update failed: $(hostname)"
        fi 
    fi
  '';

in {
  # Ensure that dependencies are installed
  environment.systemPackages = with pkgs; [ 
    bash
    git
    nixos-switch-auto
  ];

  services.cron = {
    enable = true;
    systemCronJobs = [
      "* * * * *      heywoodlh    sudo ${nixos-switch-auto}"
    ];
  };
}
