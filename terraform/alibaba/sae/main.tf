# Serverless App Engine (SAE) applications.
#
# Pattern: the live estate was originally one copy-pasted resource block per app
# (≈9 near-identical blocks). Here it's collapsed into a single `for_each` over a
# map of app definitions — change the shape once, apply to every app.
#
# SECURITY: the `envs` field carries secrets (DB password, API keys, SA keys) and
# is deliberately NOT defined here. It's managed by the deploy pipeline and
# ignored via lifecycle.ignore_changes so it never drifts into git. `image_url`
# and `replicas` are likewise ignored — they change every deploy / are driven by
# autoscaling and the off-hours scheduler.
#
# SPEC IS SOURCE OF TRUTH HERE: cpu/memory live in this file. `terraform apply`
# resizes apps in place. Floor is cpu=500 / memory=1024 (0.5 vCPU / 1 GiB);
# scale out with autoscaling rules rather than scaling these up.

locals {
  # Defaults shared by every app; per-app entries override only what differs.
  app_defaults = {
    cpu                              = 500
    memory                           = 1024
    replicas                         = 1
    package_type                     = "Image"
    batch_wait_time                  = 10
    termination_grace_period_seconds = 30
    command                          = ""
    command_args                     = []
  }
}

resource "alicloud_sae_application" "this" {
  for_each = var.applications

  app_name        = each.value.app_name
  namespace_id    = var.namespace_id
  image_url       = "${var.registry_url}/${var.acr_namespace}/${each.value.repo}:${var.environment}-bootstrap"
  acr_instance_id = var.acr_instance_id

  cpu          = coalesce(each.value.cpu, local.app_defaults.cpu)
  memory       = coalesce(each.value.memory, local.app_defaults.memory)
  replicas     = local.app_defaults.replicas
  package_type = local.app_defaults.package_type

  # Explicit entrypoint so SAE never falls back to an auto-detected (stale) one.
  command         = each.value.command
  command_args_v2 = each.value.command_args

  vpc_id            = var.vpc_id
  vswitch_id        = var.vswitch_id
  security_group_id = var.security_group_id

  batch_wait_time                  = local.app_defaults.batch_wait_time
  termination_grace_period_seconds = local.app_defaults.termination_grace_period_seconds
  timezone                         = var.timezone

  tags = merge(var.tags, { App = each.key })

  lifecycle {
    # Secrets, image tag, and replica count are managed outside Terraform.
    ignore_changes = [envs, image_url, replicas]
  }
}
