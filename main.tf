terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = ">= 7.5.0"
    }
  }
}

provider "google" {
  project = var.gcp_project_id
  region  = var.gcp_region
}

# resource "google_artifact_registry_repository" "repo" {
#   location      = var.gcp_region
#   repository_id = var.artifact_registry_repo_id
#   format        = "DOCKER"
#   description   = "Repositório Docker para a customer-api."
# }

resource "google_container_cluster" "primary" {
  name     = var.cluster_name
  location = var.gcp_zone

  remove_default_node_pool = true
  initial_node_count       = 1

  network    = "vpc-gke"
  subnetwork = "vpc-gke-subrede"

  deletion_protection = false

#Exemplo para criar regras mais restrita para o cluster o ip deve ser o externo de onde estiver acessando 
  # master_authorized_networks_config {
  #   cidr_blocks {
  #     cidr_block   = "10.10.10.10/32"
  #     display_name = "Meu IP de Acesso"
  #   }
  #   cidr_blocks {
  #     cidr_block   = "10.10.10.11/32"
  #     display_name = "IP SECUNDARIO"
  #   }
  # }

  datapath_provider = "ADVANCED_DATAPATH"

  monitoring_config {
    enable_components = ["SYSTEM_COMPONENTS"]
    managed_prometheus {
      enabled = true
    }
  }

  logging_config {
    enable_components = ["SYSTEM_COMPONENTS"]
  }

  # Habilitar o Workload Identity para acesso seguro aos serviços GCP
  workload_identity_config {
    workload_pool = "${var.gcp_project_id}.svc.id.goog"
  }

  # Habilitar o GKE Connect para gerenciamento centralizado
  release_channel {
    channel = "REGULAR"
  }

  resource_labels = {
    mesh_id = "default"
  }
}

resource "google_container_node_pool" "primary_nodes" {
  name       = "${google_container_cluster.primary.name}-node-pool"
  location   = var.gcp_zone
  cluster    = google_container_cluster.primary.name
  node_count = 2

  node_config {
    preemptible  = false #não mandar para produção
    machine_type = "e2-standard-4"
    tags         = ["tag-de-sua-preferencia"]
    oauth_scopes = [
      "https://www.googleapis.com/auth/cloud-platform"
    ]
  }
	  autoscaling {
	    min_node_count = 1
	    max_node_count = 6
	  }
}

# Cria um endereço IP estático para ser usado pelo Ingress.
resource "google_compute_global_address" "static_ip" {
  name = "nome-da-identificacao-do-seu-ip-static"
}

# Regra de firewall para permitir tráfego da Cloudflare (IPv4).
# resource "google_compute_firewall" "allow_cloudflare_ipv4" {
#   name      = "allow-cloudflare-ipv4"
#   network   = "vpc-gke"
#   direction = "INGRESS"
#   priority  = 900

#   allow {
#     protocol = "tcp"
#     ports    = ["80", "443"]
#   }

#     source_ranges = [
#         "173.245.48.0/20",
#         "103.21.244.0/22",
#         "103.22.200.0/22",
#         "103.31.4.0/22",
#         "141.101.64.0/18",
#         "108.162.192.0/18",
#         "190.93.240.0/20",
#         "188.114.96.0/20",
#         "197.234.240.0/22",
#         "198.41.128.0/17",
#         "162.158.0.0/15",
#         "104.16.0.0/13",
#         "104.24.0.0/14",
#         "172.64.0.0/13",
#         "131.0.72.0/22"
# ]   

#   target_tags = ["gke-customer-api-node"]
# }

# resource "google_compute_firewall" "allow_cloudflare_ipv6" {
#   name      = "allow-cloudflare-ipv6"
#   network   = "vpc-gke"
#   direction = "INGRESS"
#   priority  = 900

#   allow {
#     protocol = "tcp"
#     ports    = ["80", "443"]
#   }

#   source_ranges = [
#     "2400:cb00::/32", "2606:4700::/32", "2803:f800::/32", "2405:b500::/32",
#     "2405:8100::/32", "2a06:98c0::/29", "2c0f:f248::/32"
#   ]

#   target_tags = ["gke-customer-api-node"]
# }
