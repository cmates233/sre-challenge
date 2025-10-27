# Create the public DNS zone
resource "google_dns_managed_zone" "public_zone" {
  name        = var.dns_zone_name
  dns_name    = var.dns_domain
  description = var.dns_zone_description
  visibility  = "public"
}

# Health check for primary load balancer
resource "google_compute_health_check" "primary_lb" {
  name                = "${var.dns_zone_name}-primary-hc"
  check_interval_sec  = var.health_check_interval
  timeout_sec         = var.health_check_timeout
  healthy_threshold   = var.healthy_threshold
  unhealthy_threshold = var.unhealthy_threshold

  dynamic "http_health_check" {
    for_each = var.health_check_type == "HTTP" ? [1] : []
    content {
      port         = var.health_check_port
      request_path = var.health_check_path
    }
  }

  dynamic "https_health_check" {
    for_each = var.health_check_type == "HTTPS" ? [1] : []
    content {
      port         = var.health_check_port
      request_path = var.health_check_path
    }
  }
}

# Health check for secondary load balancer
resource "google_compute_health_check" "secondary_lb" {
  name                = "${var.dns_zone_name}-secondary-hc"
  check_interval_sec  = var.health_check_interval
  timeout_sec         = var.health_check_timeout
  healthy_threshold   = var.healthy_threshold
  unhealthy_threshold = var.unhealthy_threshold

  dynamic "http_health_check" {
    for_each = var.health_check_type == "HTTP" ? [1] : []
    content {
      port         = var.health_check_port
      request_path = var.health_check_path
    }
  }

  dynamic "https_health_check" {
    for_each = var.health_check_type == "HTTPS" ? [1] : []
    content {
      port         = var.health_check_port
      request_path = var.health_check_path
    }
  }
}

# DNS record with primary-backup failover
resource "google_dns_record_set" "failover" {
  name         = var.dns_record_name
  type         = "A"
  ttl          = var.dns_ttl
  managed_zone = google_dns_managed_zone.public_zone.name

  routing_policy {
    primary_backup {
      # Primary load balancer
      primary {
        internal_load_balancers {
          load_balancer_type = "globalL7ilb"
          ip_address         = var.primary_lb_ip
          port               = var.health_check_port
          ip_protocol        = "tcp"
          network_url        = var.network_self_link
          project            = var.project_id
        }
      }

      # Backup/secondary load balancer
      backup_geo {
        location = var.backup_location
        rrdatas  = [var.secondary_lb_ip]

        health_checked_targets {
          internal_load_balancers {
            load_balancer_type = "globalL7ilb"
            ip_address         = var.secondary_lb_ip
            port               = var.health_check_port
            ip_protocol        = "tcp"
            network_url        = var.network_self_link
            project            = var.project_id
          }
        }
      }

      trickle_ratio = var.trickle_ratio
    }
  }
}