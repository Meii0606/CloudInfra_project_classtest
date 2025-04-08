variable "project_id" {
    type = string
    description ="ID of the Google Project"
    default = "alien-waters-448904-q1" # align with credentials
}

variable "region" {
  type        = string
  description = "Default Region"
  default     = "us-east1"
}

variable "zone" {
  type        = string
  description = "Default Zone"
  default     = "us-east1-b"
}

variable "cloud_server_name" {
  type        = string
  description = "Name of server"
  default = "dataproc-cluster"
}

variable "master_machine_type" {
  type        = string
  description = "Machine Type"
  default     = "e2-standard-2"
}

variable "worker_machine_type" {
  type        = string
  description = "Machine Type"
  default     = "e2-standard-2"
}

variable "service_account" {
  type        = string
  description = "Service Account"
  default     = "388250803076-compute@developer.gserviceaccount.com" # align with credentials
}