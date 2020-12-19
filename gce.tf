variable "gce_ssh_user" {
  default     = "stejon"
  description = "SSH username"
}

variable "gce_ssh_pub_key_file" {
  default     = "~/.ssh/id_rsa.pub"
  description = "SSH public key"
}

resource "google_compute_address" "static" {
  name = "ipv4-address"
}

resource "google_compute_instance" "bastion" {
  name         = "${var.project_id}-bastion"
  machine_type = "e2-micro"
  zone         = var.zone

  tags = ["ssh"]

  boot_disk {
    initialize_params {
      image = "debian-cloud/debian-10"
    }
  }

  network_interface {
    network    = google_compute_network.vpc.name
    subnetwork = google_compute_subnetwork.subnet.name

    # Static IP
    access_config {
      nat_ip = google_compute_address.static.address
    }
  }

  metadata = {
    type     = "bastion"
    project  = "test"
    ssh-keys = "${var.gce_ssh_user}:${file(var.gce_ssh_pub_key_file)}"
  }

  metadata_startup_script = "echo hi > /test.txt"

  service_account {
    email  = google_service_account.bastion_sa.email
    scopes = ["userinfo-email", "compute-ro", "storage-ro"]
  }
}

output "bastion_name" {
  value       = google_compute_instance.bastion.name
  description = "GCE bastion name"
}

output "bastion_zone" {
  value       = google_compute_instance.bastion.zone
  description = "GCE bastion zone"
}

output "bastion_private_ip" {
  value       = google_compute_instance.bastion.network_interface.0.network_ip
  description = "GCE bastio private ip"
}

output "bastion_public_ip" {
  value       = google_compute_instance.bastion.network_interface.0.access_config.0.nat_ip 
  description = "GCE bastion public ip"
}

