## Nix installation

Desktop

```
nix run "git+https://tangled.org/heywoodlh.io/nixos-configs?dir=flakes/ansible#workstation
```

Server

```
nix run "git+https://tangled.org/heywoodlh.io/nixos-configs?dir=flakes/ansible#server
```

## UDM installation

As root

```bash
apt update && apt install -y git pipx
dpkg -r ansible &>/dev/null || true
pipx install ansible
export PATH="/root/.local/bin:$PATH"
/root/.local/bin/ansible-pull -U https://tangled.org/heywoodlh.io/nixos-configs flakes/ansible/server/standalone.yml
```
