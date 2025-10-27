resource "google_artifact_registry_repository" "proxy" {
  project       = var.project_id
  location      = var.location
  repository_id = var.repository_id
  description   = var.description
  format        = var.format
  mode          = "REMOTE_REPOSITORY"

  remote_repository_config {
    description                 = var.description
    disable_upstream_validation = var.disable_upstream_validation

    docker_repository {
      dynamic "custom_repository" {
        for_each = var.repository_type == "custom" ? [1] : []
        content {
          uri = var.custom_repository_uri
        }
      }

      public_repository = var.repository_type == "public" ? var.public_repository : null
    }
  }

  vulnerability_scanning_config {
    enablement_config = var.vulnerability_scanning_enablement
  }
}