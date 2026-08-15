variable "project_id" {
  description = "The new repo's own GCP project -- not the hub."
  type        = string
}

variable "region" {
  description = "Region for the new repo's state bucket."
  type        = string
  default     = "us-east1"
}

variable "github_owner" {
  description = "GitHub org the new repo lives under."
  type        = string
  default     = "gcp-terraform-repos"
}

variable "github_repo" {
  description = "The new repo's name, without the owner prefix."
  type        = string
}

# Option A inputs (string passthrough) -- from gcp-platform bootstrap's outputs.
variable "wif_pool_name" {
  description = "gcp-platform bootstrap's wif_pool_name output."
  type        = string
  default     = null
}

variable "wif_provider_name" {
  description = "gcp-platform bootstrap's wif_provider_name output."
  type        = string
  default     = null
}

# Option B input (data-source lookup).
variable "hub_project_id" {
  description = "gcp-platform hub project ID. Only used if you switch main.tf to Option B."
  type        = string
  default     = null
}
