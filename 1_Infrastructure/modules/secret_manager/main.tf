terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 5.0"
    }
  }
}

resource "google_secret_manager_secret" "secret" {
  project   = var.project_id
  secret_id = var.secret_id

  dynamic "replication" {
    for_each = var.replication_type == "auto" ? [1] : []
    content {
      auto {}
    }
  }

  dynamic "replication" {
    for_each = var.replication_type == "user_managed" ? [1] : []
    content {
      user_managed {
        dynamic "replicas" {
          for_each = var.replication_locations
          content {
            location = replicas.value
          }
        }
      }
    }
  }

  labels = var.labels
}

resource "google_secret_manager_secret_version" "secret_version" {
  secret      = google_secret_manager_secret.secret.id
  secret_data = var.secret_data
}