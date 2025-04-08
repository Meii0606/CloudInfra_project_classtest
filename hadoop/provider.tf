data "google_client_config" "default" {}

# GCP provider configuration
provider "google-beta" {
  project = var.project_id
  region  = var.region
  zone    = var.zone
  credentials = "./credentials.json"
}