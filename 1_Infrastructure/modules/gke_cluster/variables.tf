variable "cluster_name" {
  description = "Name of the GKE cluster"
  type        = string
}

variable "location" {
  description = "Location (region or zone) for the GKE cluster"
  type        = string
}

variable "project_id" {
  description = "GCP project ID"
  type        = string
}

variable "network_id" {
  description = "VPC network ID for the cluster"
  type        = string
}

variable "subnetwork_id" {
  description = "Subnetwork ID for the cluster"
  type        = string
}

variable "remove_default_node_pool" {
  description = "Remove the default node pool"
  type        = bool
  default     = true
}

variable "initial_node_count" {
  description = "Initial node count for the default pool"
  type        = number
  default     = 1
}

variable "master_authorized_networks" {
  description = "List of master authorized networks"
  type = list(object({
    cidr_block   = string
    display_name = string
  }))
  default = [
    {
      cidr_block   = "0.0.0.0/0"
      display_name = "All networks"
    }
  ]
}

variable "enable_private_nodes" {
  description = "Enable private nodes (nodes only have internal IPs)"
  type        = bool
  default     = true
}

variable "enable_private_endpoint" {
  description = "Enable private endpoint (master only accessible internally)"
  type        = bool
  default     = false
}

variable "master_ipv4_cidr_block" {
  description = "CIDR block for the master network"
  type        = string
}

variable "enable_workload_identity" {
  description = "Enable Workload Identity"
  type        = bool
  default     = true
}

variable "release_channel" {
  description = "Release channel for the cluster"
  type        = string
  default     = "STABLE"
  validation {
    condition     = contains(["RAPID", "REGULAR", "STABLE"], var.release_channel)
    error_message = "Release channel must be RAPID, REGULAR, or STABLE"
  }
}

variable "deletion_protection" {
  description = "Enable deletion protection for the cluster"
  type        = bool
  default     = false
}

# Node Pool Variables

variable "node_pool_name" {
  description = "Name of the node pool"
  type        = string
  default     = "primary-node-pool"
}

variable "node_count" {
  description = "Number of nodes in the pool"
  type        = number
  default     = 1
}

variable "min_node_count" {
  description = "Minimum number of nodes for autoscaling"
  type        = number
  default     = 1
}

variable "max_node_count" {
  description = "Maximum number of nodes for autoscaling"
  type        = number
  default     = 3
}

variable "preemptible" {
  description = "Use preemptible nodes"
  type        = bool
  default     = false
}

variable "machine_type" {
  description = "Machine type for nodes"
  type        = string
  default     = "e2-standard-2"
}

variable "disk_size_gb" {
  description = "Disk size in GB for nodes"
  type        = number
  default     = 100
}

variable "disk_type" {
  description = "Disk type for nodes"
  type        = string
  default     = "pd-standard"
}

variable "workload_metadata_mode" {
  description = "Workload metadata mode (required for Workload Identity)"
  type        = string
  default     = "GKE_METADATA"
}

variable "oauth_scopes" {
  description = "OAuth scopes for the nodes"
  type        = list(string)
  default     = ["https://www.googleapis.com/auth/cloud-platform"]
}

variable "node_labels" {
  description = "Labels to apply to nodes"
  type        = map(string)
  default     = {}
}

variable "node_tags" {
  description = "Network tags to apply to nodes"
  type        = list(string)
  default     = []
}

variable "node_metadata" {
  description = "Metadata to apply to nodes"
  type        = map(string)
  default     = {}
}

variable "auto_repair" {
  description = "Enable auto repair for nodes"
  type        = bool
  default     = true
}

variable "auto_upgrade" {
  description = "Enable auto upgrade for nodes"
  type        = bool
  default     = true
}