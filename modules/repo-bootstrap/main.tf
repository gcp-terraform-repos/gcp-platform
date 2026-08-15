/**
 * The single module a new repo's bootstrap/ calls to get everything it needs
 * to exist before its own environments can be applied: required APIs, its own
 * OpenTofu state bucket, and a CI service account scoped into gcp-platform's
 * shared WIF pool.
 *
 * Composes project-services + tf-state-bucket + wif-lookup + ci-service-account
 * so a new repo does not re-derive ~80 lines of boilerplate by copy-paste.
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
  always_on_apis = [
    "iam.googleapis.com",
    "iamcredentials.googleapis.com", # token exchange for Workload Identity Federation
    "sts.googleapis.com",            # ditto
    "storage.googleapis.com",
  ]

  ci_account_id = coalesce(var.ci_account_id, substr("${var.github_repo}-ci", 0, 30))
}

module "project_services" {
  source = "../project-services"

  project_id = var.project_id
  services   = distinct(concat(local.always_on_apis, var.activate_apis))
}

module "state_bucket" {
  count  = var.create_state_bucket ? 1 : 0
  source = "../tf-state-bucket"

  project_id = var.project_id
  region     = var.region

  depends_on = [module.project_services]
}

module "wif" {
  source = "../wif-lookup"

  hub_project_id    = var.hub_project_id
  wif_pool_id       = var.wif_pool_id
  wif_provider_id   = var.wif_provider_id
  wif_pool_name     = var.wif_pool_name
  wif_provider_name = var.wif_provider_name
}

module "ci_identity" {
  source = "../ci-service-account"

  project_id    = var.project_id
  account_id    = local.ci_account_id
  display_name  = var.ci_display_name
  description   = var.ci_description
  wif_pool_name = module.wif.pool_name
  github_owner  = var.github_owner
  github_repo   = var.github_repo
  roles         = var.ci_roles

  depends_on = [module.project_services]
}

# Bucket-scoped only -- never project-wide storage admin.
resource "google_storage_bucket_iam_member" "ci_state" {
  count = var.create_state_bucket && var.grant_state_bucket_access ? 1 : 0

  bucket = module.state_bucket[0].name
  role   = "roles/storage.objectAdmin"
  member = module.ci_identity.member
}
