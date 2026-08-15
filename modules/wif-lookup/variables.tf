variable "hub_project_id" {
  description = <<-EOT
    Project ID of the gcp-platform identity hub. When set, the pool and
    provider are looked up by data source, which requires
    roles/iam.workloadIdentityPoolViewer on this project for whoever runs the
    apply. Mutually exclusive with wif_pool_name/wif_provider_name.
  EOT
  type        = string
  default     = null
}

variable "wif_pool_id" {
  description = "Short pool id (final path component). Only used when hub_project_id is set."
  type        = string
  default     = "github-pool"
}

variable "wif_provider_id" {
  description = "Short provider id (final path component). Only used when hub_project_id is set."
  type        = string
  default     = "github-provider"
}

variable "wif_pool_name" {
  description = <<-EOT
    Full pool resource name, taken from gcp-platform bootstrap's
    wif_pool_name output. Supplying this skips the data-source lookup
    entirely and needs NO permission on the hub project. This is a
    permanently supported path, not a deprecated one -- prefer it when the
    operator cannot be granted hub read, or when bootstrap must plan while
    the hub is unavailable. Mutually exclusive with hub_project_id.
  EOT
  type        = string
  default     = null
}

variable "wif_provider_name" {
  description = "Full provider resource name. Same trade-off as wif_pool_name."
  type        = string
  default     = null
}
