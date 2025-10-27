output "vpc_id" {
  description = "The ID of the VPC network"
  value       = google_compute_network.vpc.id
}

output "vpc_name" {
  description = "The name of the VPC network"
  value       = google_compute_network.vpc.name
}

output "vpc_self_link" {
  description = "The URI of the VPC network"
  value       = google_compute_network.vpc.self_link
}

output "subnet_id" {
  description = "The ID of the subnetwork"
  value       = google_compute_subnetwork.subnet.id
}

output "subnet_name" {
  description = "The name of the subnetwork"
  value       = google_compute_subnetwork.subnet.name
}

output "subnet_self_link" {
  description = "The URI of the subnetwork"
  value       = google_compute_subnetwork.subnet.self_link
}

output "subnet_cidr" {
  description = "The CIDR range of the subnetwork"
  value       = google_compute_subnetwork.subnet.ip_cidr_range
}

output "firewall_rule_id" {
  description = "The ID of the IAP firewall rule"
  value       = google_compute_firewall.allow_iap.id
}
