/**
 * A complete, runnable example of a new repo's bootstrap/ consuming
 * gcp-platform. Copy this into the new repo's own bootstrap/ and adjust
 * activate_apis / ci_roles to what that repo's CI actually needs.
 *
 * This file is validated (init -backend=false && validate) by gcp-platform's
 * own CI on every PR, so it cannot silently drift out of sync with the
 * modules it demonstrates.
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

provider "google" {
  project = var.project_id
  region  = var.region
}

module "bootstrap" {
  source = "../../modules/repo-bootstrap"
  # In a real consuming repo, pin to a tag instead of a relative path:
  #   source = "git::https://github.com/gcp-terraform-repos/gcp-platform.git//modules/repo-bootstrap?ref=v1.1.0"

  project_id   = var.project_id
  region       = var.region
  github_owner = var.github_owner
  github_repo  = var.github_repo

  # Whatever else this repo's environments need beyond the always-on
  # iam/iamcredentials/sts/storage baseline.
  activate_apis = [
    "run.googleapis.com",
    "artifactregistry.googleapis.com",
  ]

  ci_display_name = "${var.github_repo} CI/CD"
  ci_roles = [
    "roles/run.admin",
    "roles/iam.serviceAccountUser",
  ]

  # --- WIF resolution: pick ONE of the two blocks below -------------------

  # Option A (default in this example): string passthrough. Needs NO
  # permission on the hub project -- just copy gcp-platform bootstrap's two
  # outputs.
  wif_pool_name     = var.wif_pool_name
  wif_provider_name = var.wif_provider_name

  # Option B: data-source lookup. Comment out the two lines above and
  # uncomment this instead. Needs roles/iam.workloadIdentityPoolViewer on the
  # hub project for whoever runs this apply.
  # hub_project_id = var.hub_project_id
}
