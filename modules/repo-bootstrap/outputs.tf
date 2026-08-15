output "ci_service_account_email" {
  description = "Email of the CI service account. Set as the GitHub Actions variable CI_SERVICE_ACCOUNT."
  value       = module.ci_identity.service_account_email
}

output "ci_service_account_member" {
  description = "Ready-made IAM member string, \"serviceAccount:<email>\"."
  value       = module.ci_identity.member
}

output "state_bucket" {
  description = "Name of the state bucket, or null if create_state_bucket = false."
  value       = try(module.state_bucket[0].name, null)
}

output "wif_pool_name" {
  description = "Full WIF pool resource name, however it was resolved."
  value       = module.wif.pool_name
}

output "wif_provider_name" {
  description = "Full WIF provider resource name, however it was resolved. Set as the GitHub Actions WIF_PROVIDER variable."
  value       = module.wif.provider_name
}

output "wif_resolution_mode" {
  description = "\"lookup\" if hub_project_id was used, \"static\" if wif_pool_name/wif_provider_name were passed directly."
  value       = module.wif.resolution_mode
}

output "github_variables_command" {
  description = "Copy-paste to configure the repo. These are variables, not secrets -- none of them are sensitive."
  value       = <<-EOT
    gh variable set GCP_PROJECT_ID     --repo ${var.github_owner}/${var.github_repo} --body '${var.project_id}'
    gh variable set GCP_REGION         --repo ${var.github_owner}/${var.github_repo} --body '${var.region}'
    gh variable set WIF_PROVIDER       --repo ${var.github_owner}/${var.github_repo} --body '${module.wif.provider_name}'
    gh variable set CI_SERVICE_ACCOUNT --repo ${var.github_owner}/${var.github_repo} --body '${module.ci_identity.service_account_email}'
  EOT
}
