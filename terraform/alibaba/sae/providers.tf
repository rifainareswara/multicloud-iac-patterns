terraform {
  required_version = ">= 1.5"

  required_providers {
    alicloud = {
      source  = "aliyun/alicloud"
      version = "~> 1.220"
    }
  }

  # In production this points at a remote backend (e.g. OSS) — never local state
  # in a shared repo. Configure via `terraform init -backend-config=...`.
  # backend "oss" {}
}

provider "alicloud" {
  region = var.region
  # Credentials come from environment / a named CLI profile — never hardcoded.
  # profile = "your-cli-profile"
}

variable "region" {
  description = "Alibaba Cloud region."
  type        = string
  default     = "ap-southeast-5"
}
