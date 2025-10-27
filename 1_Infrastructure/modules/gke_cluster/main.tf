resource "google_container_cluster" "private_cluster" {
  name     = var.cluster_name
  location = var.location
  network  = var.network_id
  subnetwork = var.subnetwork_id
  initial_node_count       = var.initial_node_count
  remove_default_node_pool = var.remove_default_node_pool

  master_authorized_networks_config {
    dynamic "cidr_blocks" {
      for_each = var.master_authorized_networks
      content {
        cidr_block   = cidr_blocks.value.cidr_block
        display_name = cidr_blocks.value.display_name
      }
    }
  }

  private_cluster_config {
    enable_private_nodes    = var.enable_private_nodes
    enable_private_endpoint = var.enable_private_endpoint
    master_ipv4_cidr_block  = var.master_ipv4_cidr_block
  }

  workload_identity_config {
    workload_pool = var.enable_workload_identity ? "${var.project_id}.svc.id.goog" : null
  }

  release_channel {
    channel = var.release_channel
  }

  deletion_protection = var.deletion_protection
}

resource "google_container_node_pool" "primary_nodes" {
  name       = var.node_pool_name
  cluster    = google_container_cluster.private_cluster.name
  location   = google_container_cluster.private_cluster.location
  node_count = var.node_count

  node_config {
    preemptible  = var.preemptible
    machine_type = var.machine_type
    disk_size_gb = var.disk_size_gb
    disk_type    = var.disk_type

    workload_metadata_config {
      mode = var.workload_metadata_mode
    }

    oauth_scopes = var.oauth_scopes

    labels = var.node_labels
    tags   = var.node_tags

    metadata = var.node_metadata
  }

  management {
    auto_repair  = var.auto_repair
    auto_upgrade = var.auto_upgrade
  }

  autoscaling {
    min_node_count = var.min_node_count
    max_node_count = var.max_node_count
  }
}
