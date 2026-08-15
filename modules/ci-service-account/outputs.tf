output "service_account_email" {
  description = "Email of the created CI service account. Set as the GitHub Actions variable CI_SERVICE_ACCOUNT."
  value       = google_service_account.ci.email
}
