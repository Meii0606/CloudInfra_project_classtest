data "google_compute_instance" "dataproc_master_ip_data" {
  project = var.project_id
  zone    = var.zone
  name = resource.google_dataproc_cluster.mycluster.cluster_config[0].master_config[0].instance_names[0]
}

output "dataproc_master_ip" {
  description = "Dataproc master node ip address"
  value       = data.google_compute_instance.dataproc_master_ip_data.network_interface[0].network_ip
}

data "google_compute_instance" "dataproc_worker1_ip_data" {
  project = var.project_id
  zone    = var.zone
  name = resource.google_dataproc_cluster.mycluster.cluster_config[0].worker_config[0].instance_names[0]
}

output "dataproc_worker1_ip" {
  description = "Dataproc worker node1 ip address"
  value       = data.google_compute_instance.dataproc_worker1_ip_data.network_interface[0].network_ip
}

data "google_compute_instance" "dataproc_worker2_ip_data" {
  project = var.project_id
  zone    = var.zone
  name = resource.google_dataproc_cluster.mycluster.cluster_config[0].worker_config[0].instance_names[1]
}

output "dataproc_worker2_ip" {
  description = "Dataproc worker node2 ip address"
  value       = data.google_compute_instance.dataproc_worker2_ip_data.network_interface[0].network_ip
}