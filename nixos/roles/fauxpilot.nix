{ config, pkgs, ... }:

{
  networking.firewall.allowedTCPPorts = [
    8000
    8001
    8002
  ];

  # Enable docker-nvidia
  hardware.opengl.driSupport32Bit = true;
  virtualisation.docker = {
    enableNvidia = true;
  };

  system.activationScripts.mkFauxpilotNet = ''
    ${pkgs.docker}/bin/docker network create fauxpilot &2>/dev/null || true
  '';

  system.activationScripts.buildFauxpilot = ''
    mkdir -p /opt/fauxpilot/
    [[ -d /opt/fauxpilot/src ]] || ${pkgs.git}/bin/git clone https://github.com/fauxpilot/fauxpilot.git /opt/fauxpilot/src
    ${pkgs.git}/bin/git -C /opt/fauxpilot/src pull origin main
    ${pkgs.docker}/bin/docker build -t local/heywoodlh/fauxpilot:latest /opt/fauxpilot/src -f /opt/fauxpilot/src/triton.Dockerfile
  '';

  virtualisation.oci-containers = {
    backend = "docker";
    containers = {
      fauxpilot = {
        image = "local/heywoodlh/fauxpilot:latest";
        autoStart = true;
        ports = [
          "8000-8002:8000-8002"
        ];
        volumes = [
          "/opt/fauxpilot/model:/model"
          "/opt/fauxpilot/cache:/root/.cache/huggingface"
          "/etc/localtime:/etc/localtime:ro"
        ];
        dependsOn = ["copilot-proxy"];
        extraOptions = [
          "--runtime=nvidia"
          "-e=NVIDIA_VISIBLE_DEVICES=all"
          "-e=NVIDIA_DRIVER_CAPABILITIES=compute,utility"
          "--network=fauxpilot"
          "--gpus=all"
        ];
        cmd = [
          "bash"
          "-c"
          "CUDA_VISIBLE_DEVICES=$GPUS"
          "mpirun"
          "-n"
          "1"
          "--allow-run-as-root"
          "/opt/tritonserver/bin/tritonserver"
          "--model-repository=/model"
        ];
        environment = {
          NUM_GPUS = "1";
          GPUS = "0";
        };
      };
      copilot-proxy = {
        image = "docker.io/heywoodlh/copilot-proxy:latest";
        autoStart = true;
        ports = [
          "5000:5000"
        ];
        extraOptions = [
          "--network=fauxpilot"
        ];
        cmd = [
          "uvicorn" 
          "app:app"
          "--host"
          "0.0.0.0"
          "--port"
          "5000"
        ];
      };
    };
  };
}
