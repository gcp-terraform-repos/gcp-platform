variable "project_id" {
  description = "Project that owns the state bucket."
  type        = string
}

variable "region" {
  description = "Bucket location. Restricted to Cloud Storage free-tier regions."
  type        = string
  default     = "us-east1"

  validation {
    condition     = contains(["us-east1", "us-west1", "us-central1"], var.region)
    error_message = "Cloud Storage free tier only applies to us-east1, us-west1 and us-central1."
  }
}

variable "name" {
  description = "Bucket name. Defaults to \"<project_id>-tf-state\"."
  type        = string
  default     = null
}

variable "keep_versions" {
  description = "Non-current object versions retained before deletion."
  type        = number
  default     = 20
}

variable "force_destroy" {
  description = "Allow deleting a non-empty state bucket. Keep false -- this bucket holds OpenTofu state."
  type        = bool
  default     = false
}
