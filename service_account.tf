variable "gke_service_account" {
  default     = "gke-nodes"
  description = "service account for gke nodes"
}

variable "bastion_service_account" {
  default     = "bastion"
  description = "service account for bastion instance"
}

resource "google_service_account" "gke_sa" {
  account_id   = "${var.gke_service_account}-service-account"
  display_name = "Service Account for GKE nodes"
}

resource "google_service_account" "bastion_sa" {
  account_id   = "${var.bastion_service_account}-service-account"
  display_name = "Service Account for Bastion instance"
}
