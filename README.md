# repo-example-workspaces

Sample repo proving the **shipmate** GitHub Actions generalize to the
**workspace-per-environment** IaC layout: one directory per component, with
environments modeled as OpenTofu
[workspaces](https://opentofu.org/docs/cli/config/environment-variables/#tf_workspace)
rather than separate stacks or folders. Null resources only, local backend,
**zero cloud credentials**.

The engine and its three workflows (`plan.yml` / `deploy.yml` / `drift.yml`)
are identical to the other sample repos — only the env-injection mechanism
differs. That's the point: the same actions drive all three layouts.

## Environment selection: `TF_WORKSPACE`

The environment is chosen by the **`TF_WORKSPACE`** environment variable, set
per GitHub Environment (`dev-eu`, `dev-us`). OpenTofu reads it, auto-selects the
named workspace, and auto-creates it on first use — so the plan/apply scripts
need no `tofu workspace select` step and stay byte-identical to the other
flavors. State lives under `terraform.tfstate.d/<workspace>/`.

This is the idiomatic OpenTofu mechanism for workspace-per-env in CI.
`TF_WORKSPACE` (when set) is folded into shipmate's apply-match fingerprint, so
one environment's reviewed plan can never be applied against another's.

## Toolchain

- Terramate 0.17.1
- OpenTofu 1.12.4

## Layout

```
components/
  root.tm.hcl        # codegen (empty local backend, providers, main) + plan/apply scripts
  app/               # one component stack (tagged env/dev-eu, env/dev-us)
terramate.tm.hcl     # experiments = ["scripts"]
```

Env membership is carried by Terramate **tags** (`env/dev-eu`, `env/dev-us`) —
the same slash-form convention as the other sample repos.

## Fresh-clone walkthrough

```bash
terramate generate                       # codegen into components/app
terramate list --tags env/dev-eu         # -> components/app

export TF_WORKSPACE=dev-eu               # pick the environment
cd components/app
tofu init -input=false
tofu plan -input=false -lock=false       # workspace dev-eu auto-created; random_pet to add
tofu workspace show                      # -> dev-eu
```

Switch environments by changing `TF_WORKSPACE` (e.g. `dev-us`) — no code or
workflow change, matching shipmate's dynamic-env model.

> **Windows (PowerShell):** `$env:TF_WORKSPACE = "dev-eu"` instead of `export`.

## License

Apache License 2.0 — see [LICENSE](LICENSE).
