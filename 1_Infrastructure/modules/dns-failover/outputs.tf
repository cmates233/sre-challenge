output "dns_zone_id" {
  description = "The ID of the DNS managed zone"
  value       = google_dns_managed_zone.public_zone.id
}

output "dns_zone_name" {
  description = "The name of the DNS managed zone"
  value       = google_dns_managed_zone.public_zone.name
}

output "dns_zone_name_servers" {
  description = "The name servers for the DNS zone - configure these at your domain registrar"
  value       = google_dns_managed_zone.public_zone.name_servers
}

output "dns_domain" {
  description = "The DNS domain name"
  value       = google_dns_managed_zone.public_zone.dns_name
}

output "primary_health_check_id" {
  description = "ID of the primary load balancer health check"
  value       = google_compute_health_check.primary_lb.id
}

output "secondary_health_check_id" {
  description = "ID of the secondary load balancer health check"
  value       = google_compute_health_check.secondary_lb.id
}