{ config, pkgs, ... }:

{
  pkgs.mkShell {
    buildInputs = with pkgs; [
      minikube
      kubernetes-helm
      jq
    ];
  
    shellHook = ''
      alias kubectl='minikube kubectl'
      . <(minikube completion bash)
      . <(helm completion bash)
  
      # kubectl and docker completion require the control plane to be running
      if [ $(minikube status -o json | jq -r .Host) = "Running" ]; then
              . <(kubectl completion bash)
              . <(minikube -p minikube docker-env)
      fi
    '';
}
