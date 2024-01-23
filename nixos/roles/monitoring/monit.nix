{ pkgs, config, ... }:

{
  services.monit = {
    enable = true;
    config = ''
      set daemon 30
      set log /var/log/monit.log

      check device var with path /
        if SPACE usage > 80% then alert
    '';
  };
}
