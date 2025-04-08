# Google Dataproc Cluster resource definition
resource "google_dataproc_cluster" "mycluster" {
    # Basic cluster information
    name     = var.cloud_server_name           # Cluster name from variable
    project  = var.project_id                  # GCP project ID
    region   = var.region                      # Region where the cluster will be deployed
    graceful_decommission_timeout = "120s"     # Graceful decommission timeout for preemptible nodes
    labels = {                                 # Labels for organizing and identifying resources
        foo = "bar"
    }

    # Cluster configuration
    cluster_config {
        # Enable HTTP access to cluster endpoints
        endpoint_config {
            enable_http_port_access = "true"   # Allows HTTP access for easier monitoring and debugging
        }

        # Master node configuration
        master_config {
            num_instances = 1                  # Number of master nodes (typically 1)
            machine_type  = var.master_machine_type # Machine type for the master node
            disk_config {
                boot_disk_type    = "pd-ssd"   # Disk type for faster read/write operations
                boot_disk_size_gb = 30         # Size of the boot disk in GB
            }
        }

        # Worker node configuration
        worker_config {
            num_instances = 4                  # Number of worker nodes (reduced here for cost management)
            machine_type  = var.worker_machine_type # Machine type for the worker nodes
            disk_config {
                boot_disk_size_gb = 30         # Size of the boot disk in GB for worker nodes
            }
        }

        # Software and component configuration
        software_config {
            image_version = "2.0.35-debian10"  # Dataproc image version
            override_properties = {
                "dataproc:dataproc.allow.zero.workers" = "true"  # Allows running with zero workers if needed
                "dataproc:dataproc.enable_component_gateway" = "true" # Enables the component gateway for accessing web interfaces
            }
            optional_components = ["DOCKER", "JUPYTER"] # Additional components to install on the cluster
        }

        # GCE instance configurations for the cluster
        gce_cluster_config {
            service_account = var.service_account        # Service account for the cluster to interact with GCP resources
            tags = [var.cloud_server_name]               # Network tags for firewall rules and other configurations
            zone = var.zone                              # Zone for the cluster's resources

            service_account_scopes = ["cloud-platform"]  # Full access scope for interacting with GCP resources
        }

        # Initialization action to set up monitoring with Stackdriver
        initialization_action {
            script      = "gs://dataproc-initialization-actions/stackdriver/stackdriver.sh" # Path to initialization script
            timeout_sec = 500                           # Timeout for initialization action in seconds
        }
    }
}
