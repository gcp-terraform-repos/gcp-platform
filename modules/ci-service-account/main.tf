/**
 * A CI service account, in the CONSUMING repo's own GCP project, that
 * authenticates via the shared WIF pool but is impersonable only by that
 * repo's GitHub Actions workflows.
 *
 * This module never touches the hub project: var.wif_pool_name is just a
 * string (the pool's resource name) used to build a principalSet member on a
 * binding that lives on THIS service account, in THIS project. No permission
 * on the hub project is required to call this module.
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

resource "google_service_account" "ci" {
  project      = var.project_id
  account_id   = var.account_id
  display_name = var.display_name
  description  = var.description
}

# SECURITY CRITICAL: this is the actual access boundary. The pool trusts the
# whole org (see gcp-platform/bootstrap/wif.tf); this binding is what limits
# impersonation of THIS service account to workflows from THIS repository.
resource "google_service_account_iam_member" "workload_identity" {
  service_account_id = google_service_account.ci.name
  role               = "roles/iam.workloadIdentityUser"
  member             = "principalSet://iam.googleapis.com/${var.wif_pool_name}/attribute.repository/${var.github_owner}/${var.github_repo}"
}

resource "google_project_iam_member" "ci" {
  for_each = toset(var.roles)

  project = var.project_id
  role    = each.value
  member  = "serviceAccount:${google_service_account.ci.email}"
}
