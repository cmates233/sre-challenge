variable "router_name" {
  description = "Name of the Cloud Router"
  type        = string
}

variable "network_id" {
  description = "ID of the VPC network"
  type        = string
}

variable "region" {
  description = "GCP region for the router and NAT"
  type        = string
}

variable "nat_name" {
  description = "Name of the Cloud NAT"
  type        = string
}
variable "source_subnetwork_ip_ranges_to_nat" {
  description = "How NAT should be configured per Subnetwork"
  type        = string
  default     = "ALL_SUBNETWORKS_ALL_IP_RANGES"
  
  validation {
    condition = contains([
      "ALL_SUBNETWORKS_ALL_IP_RANGES",
      "ALL_SUBNETWORKS_ALL_PRIMARY_IP_RANGES",
      "LIST_OF_SUBNETWORKS"
    ], var.source_subnetwork_ip_ranges_to_nat)
    error_message = "Must be ALL_SUBNETWORKS_ALL_IP_RANGES, ALL_SUBNETWORKS_ALL_PRIMARY_IP_RANGES, or LIST_OF_SUBNETWORKS"
  }
}

variable "nat_ip_allocate_option" {
  description = "How external IPs should be allocated for this NAT"
  type        = string
  default     = "AUTO_ONLY"
  
  validation {
    condition     = contains(["AUTO_ONLY", "MANUAL_ONLY"], var.nat_ip_allocate_option)
    error_message = "Must be AUTO_ONLY or MANUAL_ONLY"
  }
}

variable "nat_ips" {
  description = "List of self_links of external IPs (only used with MANUAL_ONLY)"
  type        = list(string)
  default     = []
}

variable "min_ports_per_vm" {
  description = "Minimum number of ports allocated to a VM"
  type        = number
  default     = 64
}

variable "max_ports_per_vm" {
  description = "Maximum number of ports allocated to a VM"
  type        = number
  default     = 65536
}

variable "enable_endpoint_independent_mapping" {
  description = "Enable endpoint independent mapping"
  type        = bool
  default     = false
}

# Logging Configuration

variable "enable_logging" {
  description = "Enable logging for Cloud NAT"
  type        = bool
  default     = true
}

variable "log_filter" {
  description = "Specifies the desired filtering of logs"
  type        = string
  default     = "ERRORS_ONLY"
  
  validation {
    condition     = contains(["ERRORS_ONLY", "TRANSLATIONS_ONLY", "ALL"], var.log_filter)
    error_message = "Must be ERRORS_ONLY, TRANSLATIONS_ONLY, or ALL"
  }
}

# Timeout Configuration

variable "icmp_idle_timeout_sec" {
  description = "Timeout (in seconds) for ICMP connections"
  type        = number
  default     = 30
}

variable "tcp_established_idle_timeout_sec" {
  description = "Timeout (in seconds) for TCP established connections"
  type        = number
  default     = 1200
}

variable "tcp_transitory_idle_timeout_sec" {
  description = "Timeout (in seconds) for TCP transitory connections"
  type        = number
  default     = 30
}

variable "udp_idle_timeout_sec" {
  description = "Timeout (in seconds) for UDP connections"
  type        = number
  default     = 30
}
