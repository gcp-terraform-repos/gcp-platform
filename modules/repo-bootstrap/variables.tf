variable "project_id" {
  description = "The consuming repo's own GCP project -- not the hub."
  type        = string
}

variable "region" {
  description = "Region for the state bucket. Must be a Cloud Storage free-tier region."
  type        = string
  default     = "us-east1"
}

variable "github_owner" {
  description = "GitHub org the consuming repo lives under."
  type        = string
  default     = "gcp-terraform-repos"
}

variable "github_repo" {
  description = "The consuming repo's name, without the owner prefix. Scopes CI impersonation to exactly this repo."
  type        = string
}

# --- APIs ---------------------------------------------------------------

variable "activate_apis" {
  description = "Additional APIs to enable, on top of the always-on iam/iamcredentials/sts/storage baseline."
  type        = list(string)
  default     = []
}

# --- State bucket ---------------------------------------------------------

variable "create_state_bucket" {
  description = "Create a Tofu state bucket in this project. Set false if the repo shares an existing bucket."
  type        = bool
  default     = true
}

variable "grant_state_bucket_access" {
  description = "Grant the CI service account objectAdmin on the state bucket only. Bucket-scoped by design -- never project-wide storage admin. Ignored if create_state_bucket is false."
  type        = bool
  default     = true
}

# --- WIF resolution (passed straight through to wif-lookup) --------------

variable "hub_project_id" {
  description = "gcp-platform hub project ID, for a data-source lookup of the WIF pool/provider. Requires roles/iam.workloadIdentityPoolViewer on the hub for whoever applies this. Mutually exclusive with wif_pool_name/wif_provider_name."
  type        = string
  default     = null
}

variable "wif_pool_id" {
  description = "Short pool id. Only used when hub_project_id is set."
  type        = string
  default     = "github-pool"
}

variable "wif_provider_id" {
  description = "Short provider id. Only used when hub_project_id is set."
  type        = string
  default     = "github-provider"
}

variable "wif_pool_name" {
  description = "Full pool resource name from gcp-platform bootstrap's wif_pool_name output. Needs no permission on the hub project. Mutually exclusive with hub_project_id."
  type        = string
  default     = null
}

variable "wif_provider_name" {
  description = "Full provider resource name from gcp-platform bootstrap's wif_provider_name output. Same trade-off as wif_pool_name."
  type        = string
  default     = null
}

# --- CI service account ---------------------------------------------------

variable "ci_account_id" {
  description = "CI service account id. Defaults to \"<github_repo>-ci\", truncated to the 30-char limit."
  type        = string
  default     = null
}

variable "ci_display_name" {
  description = "Human-readable name for the CI service account."
  type        = string
  default     = "CI/CD"
}

variable "ci_description" {
  description = "What the CI service account does; shown in the GCP console."
  type        = string
  default     = "Runs CI/CD from GitHub Actions via Workload Identity Federation"
}

variable "ci_roles" {
  description = "Project-level IAM roles for the CI service account."
  type        = list(string)
  default     = []
}
