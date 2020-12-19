variable "project_id" {
  description = "project id"
}

variable "region" {
  description = "region"
}

provider "google" {
  project = var.project_id
  region  = var.region
}

# VPC
resource "google_compute_network" "vpc" {
  name                    = "${var.project_id}-vpc"
  auto_create_subnetworks = "false"
}

# Subnet
resource "google_compute_subnetwork" "subnet" {
  name          = "${var.project_id}-subnet"
  region        = var.region
  network       = google_compute_network.vpc.name
  ip_cidr_range = "192.168.0.0/24"
  secondary_ip_range {
    range_name    = "k8s-pods-range"
    ip_cidr_range = "10.0.0.0/14"
  }
  secondary_ip_range {
    range_name    = "k8s-services-range"
    ip_cidr_range = "10.4.0.0/19"
  }
}

# TODO: Cloud nat ¿?

resource "google_compute_firewall" "ssh" {
  name    = "ssh-firewall-rules"
  network = google_compute_network.vpc.id

  allow {
    protocol = "icmp"
  }

  allow {
    protocol = "tcp"
    ports    = ["22"]
  }

  target_tags = ["ssh"]
}

output "region" {
  value       = var.region
  description = "region"
}

