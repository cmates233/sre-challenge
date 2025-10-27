output "cluster_id" {
  description = "The ID of the cluster"
  value       = google_container_cluster.private_cluster.id
}

output "cluster_name" {
  description = "The name of the cluster"
  value       = google_container_cluster.private_cluster.name
}

output "cluster_endpoint" {
  description = "The endpoint of the cluster"
  value       = google_container_cluster.private_cluster.endpoint
}

output "cluster_ca_certificate" {
  description = "The cluster CA certificate"
  value       = google_container_cluster.private_cluster.master_auth[0].cluster_ca_certificate
  sensitive   = true
}

output "cluster_location" {
  description = "The location of the cluster"
  value       = google_container_cluster.private_cluster.location
}

output "node_pool_id" {
  description = "The ID of the primary node pool"
  value       = google_container_node_pool.primary_nodes.id
}

output "node_pool_name" {
  description = "The name of the primary node pool"
  value       = google_container_node_pool.primary_nodes.name
}

output "workload_identity_pool" {
  description = "The Workload Identity pool"
  value       = var.enable_workload_identity ? "${var.project_id}.svc.id.goog" : null
}