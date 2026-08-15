output "enabled_services" {
  description = "The service names that were enabled, for use in depends_on."
  value       = [for s in google_project_service.this : s.service]
}
