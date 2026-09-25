## Nix installation

Desktop

```
nix run git+https://tangled.org/heywoodlh.io/nixos-configs#ansible-workstation
```

Server

```
nix run git+https://tangled.org/heywoodlh.io/nixos-configs#ansible-server
```

## UDM installation

As root

```bash
apt update && apt install -y git pipx
dpkg -r ansible &>/dev/null || true
pipx install ansible
export PATH="/root/.local/bin:$PATH"
/root/.local/bin/ansible-pull -U https://github.com/heywoodlh/nixos-configs ansible/server/standalone.yml
```
