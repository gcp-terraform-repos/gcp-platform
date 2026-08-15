variable "project_id" {
  description = "GCP project ID."
  type        = string
}

variable "region" {
  description = "Region for the Artifact Registry repository. Keep it equal to the consuming service's region so image pulls stay in-region."
  type        = string
}

variable "repository_id" {
  description = "Artifact Registry repository name."
  type        = string
}

variable "description" {
  description = "Repository description, shown in the console."
  type        = string
  default     = "Container images"
}

variable "cleanup_untagged_after" {
  description = "Age at which untagged layers (left behind by rebuilds) are deleted."
  type        = string
  default     = "3d"
}

variable "keep_versions" {
  description = "Image versions retained by the KEEP cleanup policy. Size this against your free-tier or budget allowance for image size -- e.g. a ~200 MB image against a 0.5 GB allowance caps this at 2."
  type        = number
  default     = 2

  validation {
    condition     = var.keep_versions >= 1 && var.keep_versions <= 10
    error_message = "keep_versions must be between 1 and 10."
  }
}
