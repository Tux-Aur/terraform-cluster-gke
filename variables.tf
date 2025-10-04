variable "gcp_project_id" {
  description = "O ID do projeto do Google Cloud."
  type        = string
  default     = "poc-iac-estudos"
}

variable "gcp_region" {
  description = "A região do Google Cloud para criar os recursos."
  type        = string
  default     = "us-central1"
}

variable "gcp_zone" {
  description = "A zona do Google Cloud para criar os recursos."
  type        = string
  default     = "us-central1-a"
}

variable "cluster_name" {
  description = "O nome do cluster GKE."
  type        = string
  default     = "nome-do-seu-cluster"
}

variable "artifact_registry_repo_id" {
  description = "O ID do repositório no Artifact Registry."
  type        = string
  default     = "nome-do-seu-repo-cloud"
}