output "name" {
  description = "Bucket name. Use as the `bucket` in each env's -backend-config."
  value       = google_storage_bucket.this.name
}

output "url" {
  description = "gs:// URL of the bucket."
  value       = google_storage_bucket.this.url
}

output "self_link" {
  description = "Bucket self link."
  value       = google_storage_bucket.this.self_link
}
