output "gke_cluster_name" {
  description = "O nome do cluster GKE criado."
  value       = google_container_cluster.primary.name
}

# output "artifact_registry_repository_url" {
#   description = "A URL do repositório no Artifact Registry."
#   value       = "${google_artifact_registry_repository.repo.location}-docker.pkg.dev/${var.gcp_project_id}/${google_artifact_registry_repository.repo.repository_id}"
# }

output "ingress_static_ip" {
  description = "O endereço IP estático para o Ingress. Você deve apontar seu DNS da Cloudflare para este IP."
  value       = google_compute_global_address.static_ip.address
}
