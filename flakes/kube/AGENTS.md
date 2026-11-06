# flakes/kube layout

- `flake.nix`: stores variables for the deployments.
- `templates`: stores templated Kubernetes manifests.
- `manifests`: stores rendered Kubernetes manifests.
  - `manifests/apps.yaml`: full list of apps that get defined in ArgoCD.
- `render.sh`: helper script to render manifests. Apps that will get codified
  in ArgoCD should be added to the list of apps in `render.sh`.

## How deployments are defined

- Each application has a template in `templates/<app>.yaml` using
  `@placeholder@` tokens (e.g. `@namespace@`, `@image@`, `@hostfolder@`).
- Each application is declared in `flakes/kube/flake.nix` under the `apps`
  attribute set as `mkKubeDrv "<app>" { src = ./templates/<app>.yaml; ... }`.
  Every `mkKubeDrv` argument named like a placeholder in the template is
  substituted into the rendered manifest (this is `pkgs.substituteAll`, so an
  argument named `namespace` fills `@namespace@`).
- Rendered output lands in `manifests/<app>.yaml`; that directory is what the
  cluster consumes. Never hand-edit `manifests/` — edit the template and
  re-render.
- Images must be pinned to explicit immutable tags (never `latest`). Verify
  the tag exists in the registry manifest (and its architecture matches the
  node) before referencing it.
- Every Deployment needs explicit CPU/memory requests and limits, with limits
  no lower than requests.

## ArgoCD

- ArgoCD runs in the `argo` namespace and manages every app listed in
  `render.sh`'s `applications` array. For each app it generates an
  `Application` in `manifests/apps.yaml` pointing at this repository
  (tangled.org mirror) with `path: flakes/kube/manifests`, one rendered file
  per app, and `syncPolicy.automated` with `prune: true` and
  `selfHeal: true`.
- This means a merged PR is the deployment mechanism: do not `kubectl apply`
  or patch production workloads imperatively. GitOps is the only path; the
  rendered manifest is authoritative.
- New ArgoCD-managed apps must be added to the `applications` array in
  `render.sh` and rendered with a bare `./render.sh` (no argument) so both the
  app manifest and `manifests/apps.yaml` are regenerated.
- Apps that are not ArgoCD-managed (or single-app updates) render with
  `./render.sh <app-name>`.
- After rendering, inspect the diff: restore any regenerated files unrelated
  to your change before committing (the manifest tree is the deployment
  input, so unrelated churn is not acceptable).

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
