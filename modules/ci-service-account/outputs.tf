output "service_account_email" {
  description = "Email of the created CI service account. Set as the GitHub Actions variable CI_SERVICE_ACCOUNT."
  value       = google_service_account.ci.email
}

output "service_account_name" {
  description = "Fully-qualified name, projects/<p>/serviceAccounts/<email>. Use as service_account_id in further IAM bindings."
  value       = google_service_account.ci.name
}

output "service_account_id" {
  description = "The short account_id, e.g. keycloak-ci."
  value       = google_service_account.ci.account_id
}

output "unique_id" {
  description = "Numeric unique ID. Stable across a delete/recreate of the same email; use it when an audit log or a deleted:serviceAccount: member must be matched."
  value       = google_service_account.ci.unique_id
}

output "member" {
  description = "Ready-made IAM member string, \"serviceAccount:<email>\". Saves every caller re-interpolating the prefix."
  value       = "serviceAccount:${google_service_account.ci.email}"
}

output "wif_principal_set" {
  description = "The principalSet:// member this SA trusts. Exported for audit -- this string IS the access boundary."
  value       = "principalSet://iam.googleapis.com/${var.wif_pool_name}/attribute.repository/${var.github_owner}/${var.github_repo}"
}
