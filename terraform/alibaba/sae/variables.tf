variable "environment" {
  description = "Deployment environment (e.g. dev, uat, prod)."
  type        = string
}

variable "namespace_id" {
  description = "SAE namespace id, e.g. <region>:<name>. Placeholder in tfvars."
  type        = string
}

variable "registry_url" {
  description = "Container registry hostname. Placeholder in tfvars."
  type        = string
}

variable "acr_namespace" {
  description = "Registry namespace / project."
  type        = string
}

variable "acr_instance_id" {
  description = "ACR (enterprise) instance id. Placeholder in tfvars."
  type        = string
}

variable "vpc_id" {
  description = "VPC id. Placeholder in tfvars."
  type        = string
}

variable "vswitch_id" {
  description = "vSwitch (subnet) id. Placeholder in tfvars."
  type        = string
}

variable "security_group_id" {
  description = "Security group id. Placeholder in tfvars."
  type        = string
}

variable "timezone" {
  description = "Container timezone."
  type        = string
  default     = "Asia/Jakarta"
}

variable "tags" {
  description = "Tags applied to every app (cost allocation, ownership)."
  type        = map(string)
  default     = {}
}

variable "applications" {
  description = <<-EOT
    Map of SAE applications. Key is a short id; value overrides defaults.
    `cpu`/`memory` are optional (fall back to module defaults).
  EOT
  type = map(object({
    app_name     = string
    repo         = string
    command      = optional(string, "")
    command_args = optional(list(string), [])
    cpu          = optional(number)
    memory       = optional(number)
  }))
}
