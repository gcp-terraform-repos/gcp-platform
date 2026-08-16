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

output "ci_service_account_email" {
  description = "Email of this repo's own CI service account. Set as the GitHub Actions variable CI_SERVICE_ACCOUNT for gcp-platform itself."
  value       = module.ci_identity.service_account_email
}

output "github_variables_command" {
  description = "Copy-paste to configure this repo's own GitHub Actions variables."
  value       = <<-EOT
    gh variable set GCP_PROJECT_ID     --repo ${var.github_owner}/gcp-platform --body '${var.project_id}'
    gh variable set WIF_PROVIDER       --repo ${var.github_owner}/gcp-platform --body '${google_iam_workload_identity_pool_provider.github.name}'
    gh variable set CI_SERVICE_ACCOUNT --repo ${var.github_owner}/gcp-platform --body '${module.ci_identity.service_account_email}'
  EOT
}
