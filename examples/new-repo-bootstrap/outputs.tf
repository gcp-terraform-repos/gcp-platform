output "github_variables_command" {
  value = module.bootstrap.github_variables_command
}

output "state_bucket" {
  value = module.bootstrap.state_bucket
}

output "ci_service_account_email" {
  value = module.bootstrap.ci_service_account_email
}
