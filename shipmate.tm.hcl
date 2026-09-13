# Workspace-per-environment: the layout derives `TF_WORKSPACE` from each
# environment's own name, which is what the per-environment `TF_WORKSPACE`
# variables used to carry. A table declaring only `layout` is complete --
# `environments` entries exist to carry a region or a cloud role, and this
# repository needs neither.
globals "shipmate" {
  layout = "workspace"
}
