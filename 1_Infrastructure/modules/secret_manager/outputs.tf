output "secret_id" {
  value       = google_secret_manager_secret.secret.secret_id
  description = "The ID of the created secret"
}

output "secret_name" {
  value       = google_secret_manager_secret.secret.name
  description = "The full resource name of the secret"
}

output "secret_version" {
  value       = google_secret_manager_secret_version.secret_version.version
  description = "The version of the secret"
}

output "secret_version_name" {
  value       = google_secret_manager_secret_version.secret_version.name
  description = "The full resource name of the secret version"
}