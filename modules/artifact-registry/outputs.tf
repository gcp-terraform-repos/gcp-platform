output "repository_id" {
  description = "Artifact Registry repository name."
  value       = google_artifact_registry_repository.this.repository_id
}

output "registry_host" {
  description = "Docker registry hostname for this repository's region."
  value       = "${var.region}-docker.pkg.dev"
}

output "image_base" {
  description = "Image path without a tag, e.g. us-east1-docker.pkg.dev/my-project/keycloak."
  value       = "${var.region}-docker.pkg.dev/${var.project_id}/${google_artifact_registry_repository.this.repository_id}"
}
