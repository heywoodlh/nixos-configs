{ config, pkgs, ... }:

{
  networking.firewall.interfaces.tailscale0.allowedTCPPorts = [ 11434 18080 ];

  # Enable docker-nvidia
  hardware.opengl.driSupport32Bit = true;
  virtualisation.docker = {
    enableNvidia = true;
  };

  virtualisation.oci-containers = {
    backend = "docker";
    containers = {
      ollama = {
        image = "docker.io/ollama/ollama:0.1.16";
        autoStart = true;
        extraOptions = [
          "--tty"
          "--network=host"
        ];
        volumes = [
          "ollama:/root/.ollama"
        ];
      };
      ollama-webui = {
        image = "ghcr.io/ollama-webui/ollama-webui:main";
        autoStart = true;
        environment = {
          OLLAMA_ORIGINS = "*";
        };
        cmd = [
          "uvicorn"
          "main:app"
          "--host"
          "0.0.0.0"
          "--port"
          "18080"
        ];
        environment = {
          OLLAMA_API_BASE_URL = "http://localhost:11434/api";
        };
        extraOptions = [
          "--network=host"
          "--add-host=host.docker.internal:host-gateway"
        ];
        dependsOn = [ "ollama" ];
      };
    };
  };
}
