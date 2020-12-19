variable "gke_num_nodes" {
  default     = 3
  description = "number of gke nodes"
}

variable "zone" {
  default     = ""
  description = "zone"
}

# GKE cluster
resource "google_container_cluster" "primary" {
  name     = "${var.project_id}-gke"
  location = var.zone

  remove_default_node_pool = true
  initial_node_count       = 1

  network    = google_compute_network.vpc.name
  subnetwork = google_compute_subnetwork.subnet.name
  ip_allocation_policy {
    cluster_secondary_range_name  = google_compute_subnetwork.subnet.secondary_ip_range.0.range_name
    services_secondary_range_name  = google_compute_subnetwork.subnet.secondary_ip_range.1.range_name
  }

  private_cluster_config {
    enable_private_nodes    = true
    enable_private_endpoint = true
    master_ipv4_cidr_block  = "172.16.0.0/28"
  }

  master_authorized_networks_config {
    cidr_blocks {
      cidr_block   = google_compute_subnetwork.subnet.ip_cidr_range 
      display_name = "Main vpc range"
    }
  }
}

# Separately Managed Node Pool
resource "google_container_node_pool" "primary_nodes" {
  name       = "${google_container_cluster.primary.name}-node-pool"
  location   = var.zone
  cluster    = google_container_cluster.primary.name
  node_count = var.gke_num_nodes

  node_config {
    service_account = google_service_account.gke_sa.email

    oauth_scopes = [
      "https://www.googleapis.com/auth/logging.write",
      "https://www.googleapis.com/auth/monitoring",
    ]

    labels = {
      env = var.project_id
    }

    # preemptible  = true
    machine_type = "e2-micro"
    tags         = ["gke-node", "${var.project_id}-gke"]
    metadata = {
      disable-legacy-endpoints = "true"
    }
  }
}

output "kubernetes_cluster_name" {
  value       = google_container_cluster.primary.name
  description = "GKE Cluster Name"
}

output "kubernetes_cluster_location" {
  value       = google_container_cluster.primary.location
  description = "Kubernetes Cluster Location"
}

output "kubernetes_cluster_private_endpoint" {
  value       = google_container_cluster.primary.private_cluster_config.0.private_endpoint
  description = "Private cluster config private endpoint"
}

output "kubernetes_cluster_public_endpoint" {
  value       = google_container_cluster.primary.private_cluster_config.0.public_endpoint
  description = "Private cluster config public endpoint"
}

