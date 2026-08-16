/**
 * Bootstrap for the platform's identity hub: the Workload Identity Federation
 * pool that every gcp-terraform-repos repo's CI authenticates through, plus
 * this repo's own state bucket.
 *
 * Chicken-and-egg: applied once with LOCAL state, then migrated into the
 * bucket it created. See README.md "First-time setup".
 */

terraform {
  required_version = ">= 1.6"

  required_providers {
    google = {
      source  = "hashicorp/google"
      version = ">= 6.0, < 8.0"
    }
  }

  backend "gcs" {
    bucket = "gcp-platform-hub-tf-state"
    prefix = "bootstrap"
  }
}

provider "google" {
  project = var.project_id
  region  = var.region
}

resource "google_project_service" "required" {
  for_each = toset([
    "iam.googleapis.com",
    "iamcredentials.googleapis.com", # token exchange for Workload Identity Federation
    "sts.googleapis.com",            # ditto
    "storage.googleapis.com",
  ])

  project = var.project_id
  service = each.value

  disable_on_destroy = false
}

resource "google_storage_bucket" "tf_state" {
  name     = "${var.project_id}-tf-state"
  location = var.region
  project  = var.project_id

  force_destroy               = false
  uniform_bucket_level_access = true
  public_access_prevention    = "enforced"

  versioning {
    enabled = true
  }

  lifecycle_rule {
    condition {
      num_newer_versions = 20
    }
    action {
      type = "Delete"
    }
  }

  depends_on = [google_project_service.required]
}

/**
 * This repo's own CI identity, so GitHub Actions can apply bootstrap/
 * changes (the WIF pool, its provider, and this bucket) without a human
 * running `tofu apply` locally each time.
 *
 * Authenticates through the very pool defined in wif.tf, in this same
 * config -- no chicken-and-egg beyond the one this repo already has (first
 * apply is local, same as every other repo's bootstrap). Once this SA
 * exists and the GitHub Actions variables below are set, subsequent changes
 * to bootstrap/ can be applied by CI.
 */
module "ci_identity" {
  source = "../modules/ci-service-account"

  project_id    = var.project_id
  account_id    = "gcp-platform-ci"
  display_name  = "gcp-platform CI/CD"
  description   = "Applies gcp-platform's bootstrap/ (the shared WIF pool + this repo's state bucket) via GitHub Actions"
  wif_pool_name = google_iam_workload_identity_pool.github.name
  github_owner  = var.github_owner
  github_repo   = "gcp-platform"

  # Exactly what applying bootstrap/main.tf and wif.tf requires -- nothing
  # broader. No storage.admin here: bucket access is granted below, scoped
  # to this one bucket, not project-wide.
  roles = [
    "roles/serviceusage.serviceUsageAdmin", # google_project_service.required
    "roles/iam.workloadIdentityPoolAdmin",  # the pool + provider in wif.tf
    "roles/iam.serviceAccountAdmin",        # manage/read module.ci_identity's own SA -- self-referential, required every apply
  ]
}

# Bucket-scoped only -- never project-wide storage admin. Covers both
# managing the bucket's own config (google_storage_bucket.tf_state) and
# reading/writing this repo's Tofu state inside it.
resource "google_storage_bucket_iam_member" "ci_state" {
  bucket = google_storage_bucket.tf_state.name
  role   = "roles/storage.admin"
  member = module.ci_identity.member
}
