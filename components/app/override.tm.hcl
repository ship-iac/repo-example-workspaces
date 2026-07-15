script "plan" {
  description = "plan (workspace override)"
  job {
    commands = [
      ["tofu", "init", "-input=false"],
      ["tofu", "workspace", "select", "-or-create", "${env.TF_VAR_env}"],
      ["tofu", "plan", "-input=false", "-lock=false", "-out=stack.otplan"],
    ]
  }
}
script "apply" {
  description = "apply (workspace override)"
  job {
    commands = [
      ["tofu", "init", "-input=false"],
      ["tofu", "workspace", "select", "-or-create", "${env.TF_VAR_env}"],
      ["tofu", "apply", "-input=false", "-lock=false", "-auto-approve", "stack.otplan"],
    ]
  }
}
