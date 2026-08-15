/**
 * Enables a set of GCP APIs on a project.
 *
 * Extracted from the near-identical `google_project_service.required` block
 * that used to be copy-pasted into every repo's bootstrap/.
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

resource "google_project_service" "this" {
  for_each = toset(var.services)

  project = var.project_id
  service = each.value

  disable_on_destroy = var.disable_on_destroy
}
