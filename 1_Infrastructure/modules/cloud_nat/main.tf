resource "google_compute_router" "router" {
  name    = var.router_name
  network = var.network_id
  region  = var.region
}

resource "google_compute_router_nat" "nat" {
  name   = var.nat_name
  router = google_compute_router.router.name
  region = google_compute_router.router.region

  source_subnetwork_ip_ranges_to_nat = var.source_subnetwork_ip_ranges_to_nat
  nat_ip_allocate_option             = var.nat_ip_allocate_option
  nat_ips                            = var.nat_ips

  min_ports_per_vm                   = var.min_ports_per_vm
  max_ports_per_vm                   = var.max_ports_per_vm
  enable_endpoint_independent_mapping = var.enable_endpoint_independent_mapping

  log_config {
    enable = var.enable_logging
    filter = var.log_filter
  }
}