variable "project_id" {
  description = "GCP project the CI service account lives in -- the consuming repo's own project, not the hub."
  type        = string
}

variable "account_id" {
  description = "Service account ID, e.g. keycloak-ci. Must be unique within project_id."
  type        = string
}

variable "display_name" {
  description = "Human-readable name for the service account."
  type        = string
}

variable "description" {
  description = "What this account does; shown in the GCP console."
  type        = string
  default     = "Runs CI/CD from GitHub Actions via Workload Identity Federation"
}

variable "wif_pool_name" {
  description = "Full resource name of the shared pool, from gcp-platform bootstrap's wif_pool_name output."
  type        = string
}

variable "github_owner" {
  description = "GitHub org the consuming repo lives under."
  type        = string
  default     = "gcp-terraform-repos"
}

variable "github_repo" {
  description = "The consuming repo's name, without the owner prefix. This is what scopes impersonation to exactly this repo."
  type        = string
}

variable "roles" {
  description = "Project-level IAM roles to grant the CI service account."
  type        = list(string)
}
