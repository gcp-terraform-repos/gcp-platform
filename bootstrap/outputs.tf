output "wif_pool_name" {
  description = "Full pool resource name. Pass this into modules/ci-service-account's wif_pool_name variable from each consuming repo."
  value       = google_iam_workload_identity_pool.github.name
}

output "wif_provider_name" {
  description = "Full provider resource name. Each consuming repo sets this as its GitHub Actions WIF_PROVIDER variable."
  value       = google_iam_workload_identity_pool_provider.github.name
}

output "state_bucket" {
  description = "Name of the GCS bucket holding this repo's own OpenTofu state."
  value       = google_storage_bucket.tf_state.name
}
