/**
 * Resolves the shared WIF pool + provider resource names, via either of two
 * mutually exclusive paths:
 *
 *   1. hub_project_id set -> look them up with data sources. Requires
 *      roles/iam.workloadIdentityPoolViewer (BETA-stage role) on the hub
 *      project for whoever runs the apply.
 *   2. wif_pool_name / wif_provider_name set -> pass the strings through
 *      as-is. Requires NO permission on the hub project at all.
 *
 * Path 2 is not a deprecated fallback -- it is the permanently supported
 * option for operators who cannot be granted hub read, or who need to plan
 * while the hub is unreachable. gcp-platform's ci-service-account module
 * documents the same "no hub permission needed" property; this module lets a
 * caller trade that property away deliberately, not by default.
 *
 * The data sources are real (verified present across the whole
 * hashicorp/google >= 6.0, < 8.0 range this repo targets), despite the
 * registry docs' stale "this resource is in beta" banner -- they ship in the
 * GA provider.
 */

terraform {
  required_version = ">= 1.6"

  required_providers {
    google = {
      source  = "hashicorp/google"
      version = ">= 6.0, < 8.0"
    }
  }
}

locals {
  use_lookup = var.hub_project_id != null
}

data "google_iam_workload_identity_pool" "github" {
  count = local.use_lookup ? 1 : 0

  project                   = var.hub_project_id
  workload_identity_pool_id = var.wif_pool_id
}

data "google_iam_workload_identity_pool_provider" "github" {
  count = local.use_lookup ? 1 : 0

  project                            = var.hub_project_id
  workload_identity_pool_id          = var.wif_pool_id
  workload_identity_pool_provider_id = var.wif_provider_id
}

locals {
  pool_name     = local.use_lookup ? data.google_iam_workload_identity_pool.github[0].name : var.wif_pool_name
  provider_name = local.use_lookup ? data.google_iam_workload_identity_pool_provider.github[0].name : var.wif_provider_name
}
