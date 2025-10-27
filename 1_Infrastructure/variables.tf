variable "project_id" {
  description = "The project ID to host the cluster in."
  type        = string
  default     = "operating-codex-476013-g6"
}

variable "region" {
  type        = string
  default     = "europe-southwest1"
}

variable "network_name" {
  type        = string
}

variable "subnetwork_name" {
  type        = string
}
variable "backup_region" {
  type        = string
  default     = "europe-west3"
}

variable "grafana_admin_password" {
  type        = string
  sensitive   = true
}

variable "main_cluster_primary_range" {
  type        = string
}

variable "cluster_release_channel" {
  type        = string
}

variable "backup_cluster_primary_range" {
  type        = string
}

variable "dns_domain" {
  type        = string
}