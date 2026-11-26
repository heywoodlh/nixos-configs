# kubernetes layout

- `flake.nix`: stores variables for the deployments.
- `templates`: stores templated Kubernetes manifests.
- `manifests`: rendered output, gitignored. CI renders it and applies it
  directly; never commit this directory.
- `render.sh`: helper script to render manifests. Apps that should be deployed
  must be added to the `applications` array in `render.sh`.

## How deployments are defined

- Each application has a template in `templates/<app>.yaml` using
  `@placeholder@` tokens (e.g. `@namespace@`, `@image@`, `@hostfolder@`).
- Each application is declared in `kubernetes/flake.nix` under the `apps`
  attribute set as `mkKubeDrv "<app>" { src = ./templates/<app>.yaml; ... }`.
  Every `mkKubeDrv` argument named like a placeholder in the template is
  substituted into the rendered manifest (this is `pkgs.substituteAll`, so an
  argument named `namespace` fills `@namespace@`).
- Rendered output lands in `manifests/<app>.yaml`. That directory is generated
  and gitignored on `main`; `kubernetes-cd.yaml` renders it and applies every
  file with `kubectl apply`. Never hand-edit `manifests/` — edit the template
  and re-render.
- Images must be pinned to explicit immutable tags (never `latest`). Verify
  the tag exists in the registry manifest (and its architecture matches the
  node) before referencing it.
- Every Deployment needs explicit CPU/memory requests and limits, with limits
  no lower than requests.

## Deployment

- ArgoCD has been retired. `kubernetes-cd.yaml` is the only deployer: on pushes
  touching `kubernetes/**` and on a weekly schedule it renders every app and
  runs `kubectl apply -f` over `manifests/*.yaml`.
- A merged PR is the deployment mechanism: do not `kubectl apply` or patch
  production workloads imperatively; the rendered manifest is authoritative.
- New apps must be added to the `applications` array in `render.sh` and
  rendered with a bare `./render.sh` (no argument).
- Single-app updates render with `./render.sh <app-name>`.
- `kubectl apply` does not prune: resources removed from a template, or apps
  removed from `render.sh`, must be deleted from the cluster explicitly.
- After rendering, inspect local output. Generated manifests are not committed
  to `main`; never add `kubernetes/manifests/` to a commit.

## Secrets

- Secrets are declaratively synchronized by the 1Password Kubernetes
  operator: templates define `OnePasswordItem` resources with
  `spec.itemPath: vaults/Kubernetes/items/<item-id>`, and the operator
  materializes a `Secret` that pods reference via `secretKeyRef`.
- Never put credential values or 1Password item IDs in rendered manifests
  beyond the `OnePasswordItem` itself, and never in commit messages or PR
  prose.
- Do not rely on Helm-generated Secrets; if a chart generates them, replace
  with `OnePasswordItem` references or existing-secret values and assert no
  chart-generated `Secret` documents remain in the rendered output.
- Namespaced resources must carry an explicit `metadata.namespace` matching
  the app's declared namespace.

## Networking conventions

- Internal same-node traffic is plaintext HTTP; remote traffic goes over
  Tailscale. Tailscale exposure uses a Service annotated with
  `tailscale.com/expose: "true"` plus `tailscale.com/hostname` and
  `tailscale.com/tags`.
- Never add Istio or public networking unless explicitly requested. Plex is
  the exception that keeps TLS for port-forwarding.
- Do not force HTTPS redirects on endpoints the user expects to stay plain
  HTTP.

## Validation and submission

- Validate before pushing: `nix-instantiate --parse` on edited Nix files,
  `nix eval` of the affected app output, and `kubectl create --dry-run=client
  -f manifests/<app>.yaml` (use `create`, not `apply`, dry-run: server-side
  dry runs may be blocked by RBAC on custom resources).
- Run the lefthook pre-commit hooks (`check-dupe-inputs`, `gen-docs`,
  `gitleaks`); watch for `gen-docs` staging unrelated `docs/options.md`
  churn and restore + `--no-verify` amend if so.
- Do not build or cache the NixOS closure locally; GitHub Actions builds on
  the pull request.
- Submit changes as pull requests from the fork to
  `heywoodlh/nixos-configs` (base `main`). Work on a dedicated branch off the
  latest upstream `main`.
