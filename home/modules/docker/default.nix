{ config, pkgs, ... }:

let
  docker-check = ''
    # Ensure docker is running
    if ! ${pkgs.docker-client}/bin/docker ps &> /dev/null
    then
      echo 'Docker does not seem to be running. Exiting'
      exit 1
    fi
  '';
  docker-multiarch = pkgs.writeShellScriptBin "docker-multiarch" ''
    ${docker-check} || exit 1
    # Enable multi-arch support
    if ! ${pkgs.docker-client}/bin/docker buildx inspect --bootstrap | grep Platforms | grep -q 'linux/amd64'
    then
       ${pkgs.docker-client}/bin/docker run --privileged --rm tonistiigi/binfmt --install all
    fi
  '';
in {
  imports = [
    ./security.nix { inherit docker-multiarch; }
  ];
  home.packages = [ docker-multiarch ];
}
