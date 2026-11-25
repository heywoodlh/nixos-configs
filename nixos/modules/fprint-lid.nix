{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.heywoodlh.fprintLid;
  sudoRules = config.security.pam.services.sudo.rules.auth;
  lidScript = pkgs.writeShellScript "fprintd-lid" ''
    if ${pkgs.gnugrep}/bin/grep -q closed ${lib.escapeShellArg cfg.path}; then
      exit 1
    fi
    true
  '';
in {
  options.heywoodlh.fprintLid = {
    enable = lib.mkEnableOption "skipping fprint auth while the laptop lid is closed";
    path = lib.mkOption {
      type = lib.types.str;
      default = "/proc/acpi/button/lid/LID/state";
      description = "Path to the lid state file.";
    };
  };

  config = lib.mkIf cfg.enable {
    security.pam.services.sudo.rules.auth.fprintd-lid = {
      order = sudoRules.fprintd.order - 10;
      control = "[success=ignore default=1]";
      modulePath = "${pkgs.linux-pam}/lib/security/pam_exec.so";
      args = ["quiet" "${lidScript}"];
    };
  };
}
