/**
 * A Docker Artifact Registry repository with a KEEP/DELETE cleanup policy.
 *
 * Promoted from gcp-keycloak-infrastructure, which used a hardcoded
 * keep_versions cap of 2 to fit inside the 0.5 GB Artifact Registry free
 * allowance for a ~200 MB image. That number is a fact about ONE consumer's
 * image size and free-tier budget, not about artifact registries in
 * general, so it stays a call-site decision (default below, with a wider
 * range) rather than a module-wide constraint.
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

resource "google_artifact_registry_repository" "this" {
  project       = var.project_id
  location      = var.region
  repository_id = var.repository_id
  description   = var.description
  format        = "DOCKER"

  cleanup_policy_dry_run = false

  # Untagged layers left behind by a rebuild are pure waste -- drop them once
  # they are old enough that no in-flight deploy still references them.
  cleanup_policies {
    id     = "delete-untagged"
    action = "DELETE"
    condition {
      tag_state  = "UNTAGGED"
      older_than = var.cleanup_untagged_after
    }
  }

  # KEEP wins over DELETE, so this is what actually bounds storage.
  cleanup_policies {
    id     = "keep-recent"
    action = "KEEP"
    most_recent_versions {
      keep_count = var.keep_versions
    }
  }
}
