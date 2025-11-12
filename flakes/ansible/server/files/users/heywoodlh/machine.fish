alias ansible-switch 'nix run \"github:heywoodlh/nixos-configs/$(git ls-remote https://github.com/heywoodlh/nixos-configs | head -1 | awk \'{print $1}\')?dir=flakes/ansible#server\"'
