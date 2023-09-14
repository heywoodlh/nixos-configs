{ config, pkgs, ... }:

let
  znc_hash = builtins.readFile /opt/znc/heywoodlh-hash;
  znc_salt = builtins.readFile /opt/znc/heywoodlh-salt;
  bitlbee_pass = builtins.readFile /opt/znc/heywoodlh-password;
in {
  services.znc = {
    enable = true;
    mutable = false;
    useLegacyConfig = false;
    openFirewall = true;
    config = {
      LoadModule = [ "webadmin" "adminlog" ];
      User.heywoodlh = {
        Admin = true;
        Nick = "heywoodlh";
        LoadModule = [ "chansaver" "controlpanel" "nickserv" ];
        Network.bitlbee = {
          Server = "nix-media.tailscale +6667 ${bitlbee_pass}";
          LoadModule = [ "simple_away" ];
          Chan = {
            "&bitlbee" = { Detached = false; };
            "&discord" = { Detached = false; };
            "&signal" = { Detached = false; };
          };
        };
        Pass.password = {
          Method = "sha256";
          Hash = "${znc_hash}";
          Salt = "${znc_salt}";
        };
      };
    };
  };
}
