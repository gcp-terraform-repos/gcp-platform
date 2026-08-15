variable "project_id" {
  description = <<-EOT
    GCP project ID for the identity hub. This should be a dedicated project --
    it holds no application resources, only the shared WIF pool and this
    repo's Tofu state. Create it (with billing enabled; required even though
    everything here is free) before the first apply.
  EOT
  type        = string
}

variable "region" {
  description = "Region for the state bucket. Must be a Cloud Storage free-tier region."
  type        = string
  default     = "us-east1"

  validation {
    condition     = contains(["us-east1", "us-west1", "us-central1"], var.region)
    error_message = "Cloud Storage free tier only applies to us-east1, us-west1 and us-central1."
  }
}

variable "github_owner" {
  description = "GitHub org that every consuming repo lives under. The pool's attribute_condition trusts this org, and only this org."
  type        = string
  default     = "gcp-terraform-repos"
}
