# Forge synchronization

The `main` branch is synchronized in both directions.

- GitHub pushes run `.github/workflows/sync-tangled.yml`, which pushes the checked-out commit to Tangled.
- Tangled pushes run `.tangled/workflows/sync-github.yml`, which pushes the checked-out commit to GitHub.
- Both workflows use a normal fast-forward push. A divergent `main` is rejected instead of being force-overwritten.

## Required secrets

Add the private half of an SSH key that has write access to `heywoodlh.io/nixos-configs` on Tangled as the GitHub Actions repository secret `TANGLED_SSH_PRIVATE_KEY`.

Add a GitHub fine-grained personal access token with repository **Contents: Read and write** permission as the Tangled repository secret `GITHUB_TOKEN`. The spindle exposes it to the workflow as an environment variable.

After adding the secrets, use the manual-dispatch controls on each forge to confirm that each direction can push successfully.
