terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 4.0"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.0"
    }
  }
}

provider "google" {
  project = var.project_id
  region  = var.region
}

resource "google_container_cluster" "jenkins_sonarqube_cluster" {
  name     = var.cluster_name
  location = var.region
  
  # Remove the default node pool
  remove_default_node_pool = true
  initial_node_count       = 1
  
  network    = google_compute_network.vpc.name
  subnetwork = google_compute_subnetwork.subnet.name

  ip_allocation_policy {
    cluster_ipv4_cidr_block  = "/16"
    services_ipv4_cidr_block = "/22"
  }
  
  timeouts {
    create = "30m"
    update = "30m"
    delete = "30m"
  }
}

resource "google_container_node_pool" "primary_nodes" {
  name       = "${var.cluster_name}-node-pool"
  location   = var.region
  cluster    = google_container_cluster.jenkins_sonarqube_cluster.name
  node_count = var.node_count

  node_config {
    oauth_scopes = [
      "https://www.googleapis.com/auth/logging.write",
      "https://www.googleapis.com/auth/monitoring",
      "https://www.googleapis.com/auth/devstorage.read_only"
    ]

    machine_type = var.machine_type
    disk_size_gb = var.disk_size_gb
    disk_type    = "pd-standard"

    metadata = {
      disable-legacy-endpoints = "true"
    }

    labels = {
      env = var.project_id
    }

    tags = ["gke-node", "${var.project_id}-gke"]
  }
  
  # Ignore changes that GKE makes to the node pool configuration
  lifecycle {
    ignore_changes = [
      node_config
    ]
  }
  
  timeouts {
    create = "30m"
    update = "30m"
    delete = "30m"
  }
}

resource "google_compute_network" "vpc" {
  name                    = "${var.cluster_name}-vpc"
  auto_create_subnetworks = false
}

resource "google_compute_subnetwork" "subnet" {
  name          = "${var.cluster_name}-subnet"
  region        = var.region
  network       = google_compute_network.vpc.name
  ip_cidr_range = "10.10.0.0/24"
  
  secondary_ip_range {
    range_name    = "services-range"
    ip_cidr_range = "10.11.0.0/22"
  }

  secondary_ip_range {
    range_name    = "pod-ranges"
    ip_cidr_range = "10.12.0.0/16"
  }
  
  # Don't try to remove secondary ranges that are already in use by GKE
  lifecycle {
    ignore_changes = [secondary_ip_range]
  }
}

# Configure kubernetes provider with the cluster credentials
data "google_client_config" "default" {}

# Defer Kubernetes provider configuration to a null resource to ensure
# GKE cluster is fully created before trying to use the Kubernetes provider
resource "null_resource" "dependency" {
  depends_on = [
    google_container_cluster.jenkins_sonarqube_cluster,
    google_container_node_pool.primary_nodes
  ]
}

module "gke_auth" {
  source = "terraform-google-modules/kubernetes-engine/google//modules/auth"
  depends_on = [
    null_resource.dependency
  ]
  project_id   = var.project_id
  location     = google_container_cluster.jenkins_sonarqube_cluster.location
  cluster_name = google_container_cluster.jenkins_sonarqube_cluster.name
}

provider "kubernetes" {
  host                   = "https://${google_container_cluster.jenkins_sonarqube_cluster.endpoint}"
  token                  = data.google_client_config.default.access_token
  cluster_ca_certificate = base64decode(google_container_cluster.jenkins_sonarqube_cluster.master_auth[0].cluster_ca_certificate)
} 