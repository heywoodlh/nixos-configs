{ config, pkgs, ... }:

# XMPP gateways for Signald and Discord
{
  networking.firewall.interfaces.tailscale0.allowedTCPPorts = [
    4444
    5280
    5281
    5582
    8888
  ];

  # Enable prosody
  services.prosody = {
    enable = true;
    admins = [
      "heywoodlh@heywoodlh.io"
    ];
    allowRegistration = true;
    dataDir = "/opt/prosody/data";
    httpPorts = [ 5280 ];
    httpInterfaces = [
      "tailscale0"
    ];
    modules = {
      admin_telnet = true;
      bosh = true;
      vcard = true;
      watchregistrations = true;
      websocket = true;
      welcome = true;
    };
    xmppComplianceSuite = false;
  };

  # Enable signald for Slidge
  services.signald = {
    enable = true;
    socketPath = "/run/signald/signald.sock";
    group = "signald";
  };
  users.users.heywoodlh.extraGroups = [ "signald" ];

  system.activationScripts.mkSlidge = ''
    ${pkgs.docker}/bin/docker network create slidge &2>/dev/null || true
  '';

  # Slidge containers
  virtualisation.oci-containers = {
    backend = "docker";
    containers = {
      slidgnal = {
        image = "docker.io/nicocool84/slidgnal:master";
        autoStart = true;
        volumes = [
          "/run/signald:/signald"
          "/opt/slidge/signal/data:/var/lib/slidge"
          "/opt/slidge/signal/python:/venv/lib/python/site-packages/legacy_module"
          "/opt/slidge/signal/web:/slidge-web"
          "/etc/localtime:/etc/localtime:ro"
        ];
        dependsOn = ["prosody"];
        extraOptions = [
          "--network=slidge"
        ];
        cmd = [
          "--server=nix-media.tailscale"
          "--port=5280"
        ];
      };

      slidcord = {
        image = "docker.io/nicocool84/slidcord:master";
        autoStart = true;
        volumes = [
          "/etc/localtime:/etc/localtime:ro"
        ];
        dependsOn = ["prosody"];
        extraOptions = [
          "--network=slidge"
        ];
      };
    };
  };
}
