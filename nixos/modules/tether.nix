{ config, lib, pkgs, tether, ... }:

with lib;

let
  cfg = config.heywoodlh.nixos.tether;
  port = "5134";
  iptablesFor = addr: if hasInfix ":" addr then "ip6tables" else "iptables";
  ruleArgs = "-i tailscale0 -p tcp --dport ${port}";
  allowRules = concatMapStrings (addr: ''
    ${iptablesFor addr} -I nixos-fw ${ruleArgs} -s ${addr} -j nixos-fw-accept
  '') cfg.allowedAddresses;
  removeAllowRules = concatMapStrings (addr: ''
    ${iptablesFor addr} -D nixos-fw ${ruleArgs} -s ${addr} -j nixos-fw-accept 2>/dev/null || true
  '') cfg.allowedAddresses;
in {
  options.heywoodlh.nixos.tether = {
    enable = mkOption {
      default = false;
      description = "Enable Tether iPhone integration, reachable only over Tailscale.";
      type = types.bool;
    };
    package = mkOption {
      default = tether.packages.${pkgs.stdenv.hostPlatform.system}.default;
      defaultText = literalExpression "tether.packages.\${system}.default";
      description = "Tether package to use.";
      type = types.package;
    };
    allowedAddresses = mkOption {
      default = [ ];
      example = [ "100.65.159.82" ];
      description = "Tailscale addresses allowed to reach tetherd; all other tailnet peers are refused.";
      type = types.listOf types.str;
    };
  };

  config = mkIf cfg.enable {
    assertions = [
      {
        assertion = !config.networking.nftables.enable;
        message = "heywoodlh.nixos.tether firewall rules require the iptables firewall backend.";
      }
    ];

    programs.tether = {
      enable = true;
      package = cfg.package;
    };

    systemd.packages = [ cfg.package ];
    systemd.user.services.tetherd.wantedBy = [ "default.target" ];

    # tailscale0 is trusted, so refuse tetherd's port before that accept rule and only allow listed peers
    networking.firewall.extraCommands = ''
      iptables -I nixos-fw ${ruleArgs} -j nixos-fw-refuse
      ip6tables -I nixos-fw ${ruleArgs} -j nixos-fw-refuse
    '' + allowRules;
    networking.firewall.extraStopCommands = removeAllowRules + ''
      iptables -D nixos-fw ${ruleArgs} -j nixos-fw-refuse 2>/dev/null || true
      ip6tables -D nixos-fw ${ruleArgs} -j nixos-fw-refuse 2>/dev/null || true
    '';
  };
}
