variable "network_name" {
  description = "Name of the VPC network"
  type        = string
}

variable "subnetwork_name" {
  description = "Name of the subnetwork"
  type        = string
}

variable "subnet_cidr" {
  description = "CIDR range for the subnetwork"
  type        = string
  default     = "10.2.0.0/16"
}

variable "region" {
  description = "GCP region for the subnetwork"
  type        = string
}

