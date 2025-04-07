variable "project_id" {
  description = "Google Cloud Project ID"
  type        = string
}

variable "region" {
  description = "GCP region to deploy resources"
  type        = string
  default     = "us-east4"
}

variable "cluster_name" {
  description = "Name of the GKE cluster"
  type        = string
  default     = "jenkins-sonarqube-cluster"
}

variable "node_count" {
  description = "Number of nodes in the GKE cluster"
  type        = number
  default     = 1
}

variable "machine_type" {
  description = "Machine type for the GKE nodes"
  type        = string
  default     = "e2-standard-2" # 2 vCPUs, 8GB memory
}

variable "disk_size_gb" {
  description = "Disk size for the GKE nodes in GB"
  type        = number
  default     = 100
} 