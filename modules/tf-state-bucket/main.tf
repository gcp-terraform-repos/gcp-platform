/**
 * A private, versioned GCS bucket for one repo's own OpenTofu state.
 *
 * Extracted from the near-identical `google_storage_bucket.tf_state` block
 * that used to be copy-pasted into every repo's bootstrap/. The free-tier
 * region validation lives here -- once, at the place it's actually about --
 * instead of being duplicated into every repo's variables.tf.
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
  bucket_name = coalesce(var.name, "${var.project_id}-tf-state")
}

resource "google_storage_bucket" "this" {
  name     = local.bucket_name
  location = var.region
  project  = var.project_id

  force_destroy               = var.force_destroy
  uniform_bucket_level_access = true
  public_access_prevention    = "enforced"

  versioning {
    enabled = true
  }

  lifecycle_rule {
    condition {
      num_newer_versions = var.keep_versions
    }
    action {
      type = "Delete"
    }
  }
}
