{ config, pkgs, ... }:

{
  # Placed in home dir for ease over Apple Shortcuts :)
  home-manager.users.heywoodlh.home.file = {
    "bin/wake-oryx.sh" = {
      enable = true;
      executable = true;
      text = ''
        set -ex

        targetmac="54:BF:64:96:0B:C6"
        targetip="192.168.50.255"
        targetport="9"

        ${pkgs.wakeonlan}/bin/wakeonlan -i $targetip -p $targetport $targetmac
      '';
    };
    "bin/wake-corsair.sh" = {
      enable = true;
      executable = true;
      text = ''
        set -ex

        targetmac="10:FF:E0:4E:A7:A9"
        targetip="192.168.50.255"
        targetport="9"

        ${pkgs.wakeonlan}/bin/wakeonlan -i 192.168.50.255 -p $targetport $targetmac
      '';
    };


  };
}
