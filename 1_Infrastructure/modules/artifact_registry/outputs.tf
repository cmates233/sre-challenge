output "repository_id" {
  description = "ID of the created repo"
  value       = google_artifact_registry_repository.proxy.id
}

output "repository_name" {
  description = "Name of the repo"
  value       = google_artifact_registry_repository.proxy.name
}

output "repository_url" {
  description = "URL to use for pulling images from this repository"
  value       = "${var.location}-docker.pkg.dev/${var.project_id}/${var.repository_id}"
}