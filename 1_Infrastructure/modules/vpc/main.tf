resource "google_compute_network" "vpc" {
  name                    = var.network_name
  auto_create_subnetworks = false
}

resource "google_compute_subnetwork" "subnet" {
  name          = var.subnetwork_name
  ip_cidr_range = var.subnet_cidr
  network       = google_compute_network.vpc.id
  region        = var.region
}

resource "google_compute_subnetwork" "backup_subnet" {
  name          = var.backup_subnetwork_name
  ip_cidr_range = var.backup_subnet_cidr
  network       = google_compute_network.vpc.id
  region        = var.backup_region
}

resource "google_compute_firewall" "allow_iap" {
  name    = "${var.network_name}-allow-iap-ingress"
  network = google_compute_network.vpc.name
  
  description = "Allow ingress from IAP"
  direction   = "INGRESS"
  priority    = 1000

  allow {
    protocol = "tcp"
    ports    = ["22", "3389"]
  }

  source_ranges = ["35.235.240.0/20"]
  target_tags   = null
}