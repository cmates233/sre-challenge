variable "project_id" {
  description = "GCP Project ID"
  type        = string
}

variable "secret_id" {
  description = "Secret ID in Secret Manager"
  type        = string
}

variable "secret_data" {
  description = "The secret token/data to store"
  type        = string
  sensitive   = true
}

variable "replication_type" {
  description = "Replication type: 'auto' or 'user_managed'"
  type        = string
  default     = "auto"
}

variable "replication_locations" {
  description = "Locations for user-managed replication"
  type        = list(string)
  default     = []
}

variable "labels" {
  description = "Labels to apply to the secret"
  type        = map(string)
  default = {
    managed_by = "terraform"
  }
}