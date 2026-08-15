variable "project_id" {
  description = "Project to enable the APIs in."
  type        = string
}

variable "services" {
  description = "Fully-qualified service names to enable, e.g. run.googleapis.com."
  type        = list(string)
}

variable "disable_on_destroy" {
  description = <<-EOT
    Whether to disable these APIs when this config is destroyed. Defaults to
    false: disabling an API breaks every other resource in the project that
    depends on it, which is almost never what a targeted destroy intends.
  EOT
  type        = bool
  default     = false
}
