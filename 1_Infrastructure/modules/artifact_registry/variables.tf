variable "project_id" {
  description = "GCP project ID"
  type        = string
}
variable "format" {
  description = "repo format"
  type        = string
}

variable "location" {
  description = "Location for the repository"
  type        = string
}

variable "repository_id" {
  description = "The ID of the repository"
  type        = string
}

variable "description" {
  description = "Description of the repository"
  type        = string
  default     = ""
}

variable "repository_type" {
  description = "Type of repository: 'custom' or 'public'"
  type        = string
  validation {
    condition     = contains(["custom", "public"], var.repository_type)
    error_message = "repository_type must be either 'custom' or 'public'"
  }
}

variable "custom_repository_uri" {
  description = "URI for custom repository (required when repository_type is 'custom')"
  type        = string
  default     = null
}

variable "public_repository" {
  description = "Public repository name (required when repository_type is 'public'). Options: DOCKER_HUB, etc."
  type        = string
  default     = null
}

variable "disable_upstream_validation" {
  description = "Whether to disable upstream validation"
  type        = bool
  default     = false
}