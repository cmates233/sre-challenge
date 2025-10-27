# Provider definition
provider "google" {
  project = var.project_id
  region  = var.region
}

data "google_client_config" "default" {}

provider "kubernetes" {
  alias                  = "primary"
  host                   = "https://${module.gke_cluster.cluster_endpoint}"
  token                  = data.google_client_config.default.access_token
  cluster_ca_certificate = base64decode(module.gke_cluster.cluster_ca_certificate)
}

provider "kubernetes" {
  alias                   = "backup"
  host                   = "https://${module.gke_backup_cluster.cluster_endpoint}"
  token                  = data.google_client_config.default.access_token
  cluster_ca_certificate = base64decode(module.gke_backup_cluster.cluster_ca_certificate)
}

provider "helm" {
  alias                    = "primary"
  kubernetes = {
    host                   = "https://${module.gke_cluster.cluster_endpoint}"
    token                  = data.google_client_config.default.access_token
    cluster_ca_certificate = base64decode(module.gke_cluster.cluster_ca_certificate)
  }
}

provider "helm" {
  alias                    = "backup"
  kubernetes = {
    host                   = "https://${module.gke_backup_cluster.cluster_endpoint}"
    token                  = data.google_client_config.default.access_token
    cluster_ca_certificate = base64decode(module.gke_backup_cluster.cluster_ca_certificate)
  }
}
#Start with Artifact Registry proxy repos
module "quay_proxy" {
  source = "./modules/artifact_registry"

  project_id            = var.project_id
  location              = var.region
  repository_id         = "quay-proxy"
  description           = "Pull-through cache for quay.io"
  repository_type       = "custom"
  custom_repository_uri = "https://quay.io"
  format                = "DOCKER"

}

module "dockerhub_proxy" {
  source = "./modules/artifact_registry"

  project_id                  = var.project_id
  location                    = var.region
  repository_id               = "dockerhub-proxy"
  description                 = "docker hub with custom credentials"
  repository_type             = "public"
  public_repository           = "DOCKER_HUB"
  format                      = "DOCKER"
}

#Create the admin password secret for grafana.
module "grafana_password" {
  source = "./modules/secret_manager"

  project_id  = var.project_id
  secret_id   = "grafana-admin-password"
  secret_data = var.grafana_admin_password
}

#Create the VPC, the subnets and the IAP firewall rule.
module "vpc" {
  source = "./modules/vpc"

  network_name    = "gke-network"
  subnetwork_name = "gke-subnet"
  backup_subnetwork_name = "backup-gke"
  region          = var.region
  backup_region   = var.backup_region
}

#Create Cloud Router + NAT
module "cloud_nat" {
  source = "./modules/cloud_nat"

  router_name = "${var.network_name}-router"
  nat_name    = "${var.network_name}-nat-gateway"
  network_id  = module.vpc.vpc_id
  region      = var.region

  source_subnetwork_ip_ranges_to_nat = "ALL_SUBNETWORKS_ALL_IP_RANGES"
  nat_ip_allocate_option             = "AUTO_ONLY"

  enable_logging = true
  log_filter     = "ERRORS_ONLY"

  min_ports_per_vm = 64
  max_ports_per_vm = 65536
}

#Create main GKE cluster
module "gke_cluster" {
  source = "./modules/gke_cluster"

  cluster_name  = "primary-cluster"
  location      = var.region
  project_id    = var.project_id
  network_id    = module.vpc.vpc_id
  subnetwork_id = module.vpc.subnet_id

  initial_node_count       = 1

  enable_private_nodes    = true
  enable_private_endpoint = false
  master_ipv4_cidr_block  = var.main_cluster_primary_range

  master_authorized_networks = [
    {
      cidr_block   = "0.0.0.0/0"
      display_name = "All networks"
    }
  ]

  enable_workload_identity = true
  release_channel          = var.cluster_release_channel

  node_pool_name = "primary-node-pool"
  node_count     = 1
  min_node_count = 1
  max_node_count = 3
  machine_type   = "e2-standard-2"
  preemptible    = false

  auto_repair  = true
  auto_upgrade = true
}

module "gke_backup_cluster" {
  source = "./modules/gke_cluster"
  cluster_name  = "backup-cluster"
  location      = var.backup_region
  project_id    = var.project_id
  network_id    = module.vpc.vpc_id
  subnetwork_id = module.vpc.backup_subnet_id

  initial_node_count       = 1

  enable_private_nodes    = true
  enable_private_endpoint = false
  master_ipv4_cidr_block  = var.backup_cluster_primary_range

  master_authorized_networks = [
    {
      cidr_block   = "0.0.0.0/0"
      display_name = "All networks"
    }
  ]

  enable_workload_identity = true
  release_channel          = var.cluster_release_channel

  node_pool_name = "primary-node-pool"
  node_count     = 1
  min_node_count = 1
  max_node_count = 3
  machine_type   = "e2-standard-2"
  preemptible    = false

  auto_repair  = true
  auto_upgrade = true
}

#Deploy our application - Repo already exists.
resource "kubernetes_deployment" "my_go_app_primary" {
  provider = kubernetes.primary
  metadata {
    name = "my-go-app"
  }

  spec {
    replicas = 3

    selector {
      match_labels = {
        app = "my-go-app"
      }
    }

    template {
      metadata {
        labels = {
          app = "my-go-app"
        }
      }

      spec {
        container {
          name  = "my-go-app"
          image = "${var.region}.pkg.dev/${var.project_id}/my-app-repo/my-go-app:latest"

          port {
            container_port = 443
          }
        }
      }
    }
  }
}

# Service resource
resource "kubernetes_service" "my_go_app_service_primary" {
  provider = kubernetes.primary
  metadata {
    name = "my-go-app-service"
  }

  spec {
    type = "LoadBalancer"

    selector = {
      app = "my-go-app"
    }

    port {
      protocol    = "TCP"
      port        = 443
      target_port = 443
    }
  }
}


#Now we deploy the same into the backup cluster.
resource "kubernetes_deployment" "my_go_app_backup" {
  provider = kubernetes.backup
  metadata {
    name = "my-go-app"
  }

  spec {
    replicas = 1

    selector {
      match_labels = {
        app = "my-go-app"
      }
    }

    template {
      metadata {
        labels = {
          app = "my-go-app"
        }
      }

      spec {
        container {
          name  = "my-go-app"
          image = "${var.region}.pkg.dev/${var.project_id}/my-app-repo/my-go-app:latest"

          port {
            container_port = 443
          }
        }
      }
    }
  }
}

# Backup Service resource
resource "kubernetes_service" "my_go_app_service_backup" {
  provider = kubernetes.backup
  metadata {
    name = "my-go-app-service"
  }

  spec {
    type = "LoadBalancer"

    selector = {
      app = "my-go-app"
    }

    port {
      protocol    = "TCP"
      port        = 443
      target_port = 443
    }
  }
}

#With all the info from the LBs, we create the split zone DNS.
module "dns_failover" {
  source = "./modules/dns-failover"

  project_id        = var.project_id
  dns_zone_name     = "public-zone"
  dns_domain        = var.dns_domain
  dns_record_name   = var.dns_domain
  network_self_link = module.vpc.vpc_self_link

  # Load balancer IPs
  primary_lb_ip   = kubernetes_service.my_go_app_service_primary.status.0.load_balancer.0.ingress.0.ip
  secondary_lb_ip = kubernetes_service.my_go_app_service_backup.status.0.load_balancer.0.ingress.0.ip
  backup_location = var.backup_region

  # Health check configuration
  health_check_type     = "HTTPS"
  health_check_port     = 443
  health_check_path     = "/"
  health_check_interval = 10
  health_check_timeout  = 5
  healthy_threshold     = 2
  unhealthy_threshold   = 3

  # DNS TTL - lower = faster failover
  dns_ttl = 60
}

output "name_servers" {
  description = "Configure these name servers at your domain registrar"
  value       = module.dns_failover.dns_zone_name_servers
}

#We install the monitoring suite in the main cluster.
resource "helm_release" "grafana" {
  provider = helm.primary
  name       = "grafana"
  repository = "https://grafana.github.io/helm-charts"
  chart      = "grafana"
  namespace  = "monitoring"
  create_namespace = true
  
  values = [
    templatefile("grafana-values.yaml.tpl", {
      project_id = var.project_id
      region = var.region
      password = var.grafana_admin_password
    })
  ]
}

resource "helm_release" "kube-prometheus" {
  provider = helm.primary
  name       = "kube-prometheus-stackr"
  namespace  = "monitoring"
  repository = "https://prometheus-community.github.io/helm-charts"
  version    = "25.24.1"
  chart      = "prometheus"
  values = [
    templatefile("prometheus-values.yaml.tpl", {
      project_id = var.project_id
      region = var.region
    })
  ]
}

#And do the same for the backup one.
resource "helm_release" "grafana_backup" {
  provider = helm.backup
  name       = "grafana"
  repository = "https://grafana.github.io/helm-charts"
  chart      = "grafana"
  namespace  = "monitoring"
  create_namespace = true
  
  values = [
    templatefile("grafana-values.yaml.tpl", {
      project_id = var.project_id
      region = var.region
      password = var.grafana_admin_password
    })
  ]
}

resource "helm_release" "kube-prometheus_backup" {
  provider = helm.backup
  name       = "kube-prometheus-stackr"
  namespace  = "monitoring"
  repository = "https://prometheus-community.github.io/helm-charts"
  version    = "25.24.1"
  chart      = "prometheus"
  values = [
    templatefile("prometheus-values.yaml.tpl", {
      project_id = var.project_id
      region = var.region
    })
  ]
}