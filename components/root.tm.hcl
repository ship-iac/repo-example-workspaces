generate_hcl "_backend.tf" {
  content {
    # workspace-scoped local state (terraform.tfstate.d/<ws>)
    terraform {
      backend "local" {}
    }
  }
}
generate_hcl "_providers.tf" {
  content {
    terraform {
      required_providers {
        random = {
          source  = "hashicorp/random"
          version = "~> 3.0"
        }
      }
    }
  }
}
# No _variables.tf: this flavor selects the env via the OpenTofu workspace, not
# tofu variables. The workspace is chosen by the TF_WORKSPACE env var (set per
# GitHub Environment) — OpenTofu auto-selects and auto-creates it, so the base
# plan/apply scripts below need no `workspace select` step. Declaring unused
# required vars here would break `tofu plan -input=false`.
generate_hcl "_main.tf" {
  content {
    resource "random_pet" "this" {}
    output "name" { value = random_pet.this.id }
  }
}
# Plan/apply scripts. No `tofu workspace select` step: TF_WORKSPACE (from the
# GitHub Environment) tells OpenTofu which workspace to use, auto-creating it.
script "plan" {
  description = "plan"
  job { commands = [["tofu", "init", "-input=false"], ["tofu", "plan", "-input=false", "-lock=false", "-out=stack.otplan"]] }
}
script "apply" {
  description = "apply"
  job { commands = [["tofu", "init", "-input=false"], ["tofu", "apply", "-input=false", "-lock=false", "-auto-approve", "stack.otplan"]] }
}
