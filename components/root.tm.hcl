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
generate_hcl "_variables.tf" {
  content {
    variable "env" { type = string }
    variable "region" { type = string }
  }
}
generate_hcl "_main.tf" {
  content {
    resource "random_pet" "this" {}
    output "name" { value = random_pet.this.id }
  }
}
# BASE scripts: no workspace step (overridden below)
script "plan" {
  description = "plan (base)"
  job { commands = [["tofu","init","-input=false"],["tofu","plan","-input=false","-lock=false","-out=stack.otplan"]] }
}
script "apply" {
  description = "apply (base)"
  job { commands = [["tofu","init","-input=false"],["tofu","apply","-input=false","-lock=false","-auto-approve","stack.otplan"]] }
}
