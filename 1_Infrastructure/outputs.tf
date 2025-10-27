output "vpc_id" {
  value = module.vpc.vpc_id
}

output "subnet_id" {
  value = module.vpc.subnet_id
}


output "router_id" {
  value = module.cloud_nat.router_id
}

output "nat_id" {
  value = module.cloud_nat.nat_id
}

output "cluster_endpoint" {
  value = module.gke_cluster.cluster_endpoint
}

output "cluster_name" {
  value = module.gke_cluster.cluster_name
}

output "ca_certificate_primary" {
  value       = module.gke_cluster.cluster_ca_certificate
  sensitive   = true  
}

output "cluster_backup_endpoint" {
  value = module.gke_backup_cluster.cluster_endpoint
}

output "cluster_backup_name" {
  value = module.gke_backup_cluster.cluster_name
}

output "ca_certificate_backup" {
  value       = module.gke_backup_cluster.cluster_ca_certificate
  sensitive   = true 
}
output "loadbalancer_ip_backup" {
  value       = kubernetes_service.my_go_app_service_backup.status.0.load_balancer.0.ingress.0.ip
}

output "grafana_secret_name" {
  value       = module.grafana_password.secret_name
}

output "grafana_secret_id" {
 value        = module.grafana_password.secret_id
}

   output "loadbalancer_ip_primary" {
  value       = kubernetes_service.my_go_app_service_primary.status.0.load_balancer.0.ingress.0.ip
  description = "The external IP address of the LoadBalancer"
}