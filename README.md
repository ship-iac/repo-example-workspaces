# repo-example-workspaces

Sample repo proving shipmate generalizes to the **workspace-per-environment**
IaC layout: one directory per component, environments modeled as OpenTofu
[workspaces](https://opentofu.org/docs/cli/config/environment-variables/#tf_workspace)
rather than separate stacks or folders. Null resources only, local backend,
zero cloud credentials.

## Environment selection: `TF_WORKSPACE`

The environment is chosen by the **`TF_WORKSPACE`** environment variable, set
per GitHub Environment (`dev-eu`, `dev-us`). OpenTofu reads it, auto-selects
the named workspace, and auto-creates it on first use — so the plan/apply
scripts need no `tofu workspace select` step and stay identical to the other
flavors. State lives under `terraform.tfstate.d/<workspace>/`.

This is the idiomatic OpenTofu mechanism for workspace-per-env in CI.

## Layout

```
components/
  root.tm.hcl        # globals-free: codegen (empty local backend, providers, main) + plan/apply scripts
  app/               # one component stack (tagged env/dev-eu, env/dev-us)
terramate.tm.hcl     # experiments = ["scripts"]
```

Env membership is carried by Terramate **tags** (`env/dev-eu`, `env/dev-us`) —
the same slash-form convention as the other sample repos.

## Fresh-clone walkthrough (Windows PowerShell)

```powershell
# winget-installed terramate/tofu aren't on the default PATH:
$env:Path = [System.Environment]::GetEnvironmentVariable("Path","Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path","User")

terramate generate                       # codegen into components/app
terramate list --tags env/dev-eu         # -> components/app

$env:TF_WORKSPACE = "dev-eu"             # pick the environment
cd components/app
tofu init -input=false
tofu plan -input=false -lock=false       # workspace dev-eu auto-created; random_pet to add
tofu workspace show                      # -> dev-eu
```

Switch environments by changing `TF_WORKSPACE` (e.g. `dev-us`) — no code or
workflow change, matching shipmate's dynamic-env model.
