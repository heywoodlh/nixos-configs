{
  config,
  lib,
  pkgs,
  nixpkgs-pam-lid-fix,
  ...
}: let
  cfg = config.services.fprintd.lid;
  sudoRules = config.security.pam.services.sudo.rules.auth;
  lidScript = pkgs.writeShellScript "fprintd-lid" ''
    if ${pkgs.gnugrep}/bin/grep -q closed ${lib.escapeShellArg cfg.path}; then
      exit 1
    fi
    true
  '';
in {
  imports = [
    (nixpkgs-pam-lid-fix + "/nixos/modules/services/security/fprintd.nix")
  ];
  disabledModules = ["services/security/fprintd.nix"];

  config = lib.mkIf cfg.authSkipLidClose {
    security.pam.services.sudo.rules.auth.fprintd-lid = {
      order = sudoRules.fprintd.order - 10;
      control = "[success=ignore default=1]";
      modulePath = "${pkgs.linux-pam}/lib/security/pam_exec.so";
      args = ["quiet" "${lidScript}"];
    };
  };
}
