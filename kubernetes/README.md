## How to use this flake

Build an output specified in `flake.nix` like so (not all outputs are impure):

```
nix build -o ./result .#tailscale-operator --impure
kubectl apply -f ./result
```

## Notes on node setup

Initial setup:

```
# 1Password operator
op connect server create k3s-cluster --vaults Kubernetes && mv 1password-credentials.json /tmp/
op connect token create --server k3s-cluster --vault Kubernetes k3s-cluster > /tmp/token.txt
nix build .#1password-connect --impure && kubectl apply -f ./result

# Tailscale operator
kubectl create ns tailscale
nix run .#1password-item -- --name operator-oauth --namespace tailscale --itemPath "vaults/Kubernetes/items/bwmt642lsbd5drsjcrxxnljkku" | kubectl apply -f -
nix build .#tailscale-operator && kubectl apply -f ./result

# ArgoCD
kubectl create ns argo
nix build .#argo && kubectl apply -f ./result
kubectl apply -f ./kubectl/argo-nix-configmap.yaml # delete the argocd-server pod after applying

# ArgoCD apps
kubectl apply -f manifests/apps.yaml

# Intel GPU device plugin (ArgoCD apps not managed by CI/CD)
kubectl apply -f manifests/intel-device-plugin.yaml
```

## 1Password usage with Kubernetes Operator

Create a 1Password entry with the CLI:

```
op item create --category=login --title='some-secret' --vault='Kubernetes' \
    'somefield=somevalue' \
    'someotherfield=someothervalue'
```

Alternatively, inject arbitrary fields into an existing 1Password entry with the 1Password CLI:

```
op item edit 'UUID' 'somefield=somevalue'
```

### Generate a OnePasswordItem:

If I had a 1Password entry with the following criteria:
- Desired secret name: `cloudflared`
- Desired namespace: `default`
- Item path: `vaults/Kubernetes/items/m4i7whzvm5amrmxntpoleuaxxe`

I would use the following command to generate a OnePasswordItem:

```
nix run .#1password-item -- --name cloudflared --namespace default --itemPath "vaults/Kubernetes/items/m4i7whzvm5amrmxntpoleuaxxe"
```


