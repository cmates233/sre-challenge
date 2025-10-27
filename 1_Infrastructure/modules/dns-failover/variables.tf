variable "project_id" {
  description = "GCP project ID"
  type        = string
}

variable "dns_zone_name" {
  description = "Name of the DNS managed zone"
  type        = string
}

variable "dns_domain" {
  description = "DNS domain name (must end with a dot, e.g., example.com.)"
  type        = string
}

variable "dns_zone_description" {
  description = "Description of the DNS zone"
  type        = string
  default     = "Public DNS zone with health check failover"
}

variable "dns_record_name" {
  description = "DNS record name (FQDN, must end with a dot)"
  type        = string
}

variable "dns_ttl" {
  description = "TTL for DNS records in seconds"
  type        = number
  default     = 60
}

variable "network_self_link" {
  description = "Self link of the VPC network"
  type        = string
}

# Load Balancer Configuration

variable "primary_lb_ip" {
  description = "IP address of the primary load balancer"
  type        = string
}

variable "secondary_lb_ip" {
  description = "IP address of the secondary load balancer"
  type        = string
}

variable "backup_location" {
  description = "GCP region for the backup load balancer"
  type        = string
  default     = "us-central1"
}

variable "trickle_ratio" {
  description = "Percentage of traffic to send to backup when primary is healthy (0.0-1.0)"
  type        = number
  default     = 0.0
}

# Health Check Configuration

variable "health_check_type" {
  description = "Type of health check (HTTP or HTTPS)"
  type        = string
  default     = "HTTP"

  validation {
    condition     = contains(["HTTP", "HTTPS"], var.health_check_type)
    error_message = "Health check type must be HTTP or HTTPS"
  }
}

variable "health_check_port" {
  description = "Port for health checks"
  type        = number
  default     = 80
}

variable "health_check_path" {
  description = "Path for HTTP/HTTPS health checks"
  type        = string
  default     = "/health"
}

variable "health_check_interval" {
  description = "Health check interval in seconds"
  type        = number
  default     = 10
}

variable "health_check_timeout" {
  description = "Health check timeout in seconds"
  type        = number
  default     = 5
}

variable "healthy_threshold" {
  description = "Number of consecutive successful checks before marking healthy"
  type        = number
  default     = 2
}

variable "unhealthy_threshold" {
  description = "Number of consecutive failed checks before marking unhealthy"
  type        = number
  default     = 2
}
