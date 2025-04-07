# Kubernetes Job to initialize volumes with backup data
resource "kubernetes_job" "initialize_jenkins_data" {
  metadata {
    name      = "initialize-jenkins-data"
    namespace = kubernetes_namespace.jenkins_sonarqube.metadata[0].name
  }
  spec {
    template {
      metadata {}
      spec {
        container {
          name    = "data-initializer"
          image   = "google/cloud-sdk:slim"
          command = ["/bin/sh", "-c"]
          args = [
            <<-EOT
            # Download Jenkins data backup
            gsutil cp gs://jenkins-sonarqube-backups/jenkins_home_backup.tar.gz /tmp/
            # Extract to the mount point
            tar -xzf /tmp/jenkins_home_backup.tar.gz -C /jenkins-data
            # Set proper permissions
            chmod -R 777 /jenkins-data
            EOT
          ]
          volume_mount {
            name       = "jenkins-data"
            mount_path = "/jenkins-data"
          }
        }
        volume {
          name = "jenkins-data"
          persistent_volume_claim {
            claim_name = kubernetes_persistent_volume_claim.jenkins_pvc.metadata[0].name
          }
        }
        restart_policy = "Never"
      }
    }
    backoff_limit = 4
  }
  wait_for_completion = true
  timeouts {
    create = "30m"
  }
  depends_on = [
    kubernetes_persistent_volume_claim.jenkins_pvc
  ]
}

resource "kubernetes_job" "initialize_sonarqube_data" {
  metadata {
    name      = "initialize-sonarqube-data"
    namespace = kubernetes_namespace.jenkins_sonarqube.metadata[0].name
  }
  spec {
    template {
      metadata {}
      spec {
        container {
          name    = "data-initializer"
          image   = "google/cloud-sdk:slim"
          command = ["/bin/sh", "-c"]
          args = [
            <<-EOT
            # Download SonarQube data backup
            gsutil cp gs://jenkins-sonarqube-backups/sonarqube_data_backup.tar.gz /tmp/
            # Extract to the mount point
            tar -xzf /tmp/sonarqube_data_backup.tar.gz -C /sonarqube-data
            # Set proper permissions
            chmod -R 777 /sonarqube-data
            EOT
          ]
          volume_mount {
            name       = "sonarqube-data"
            mount_path = "/sonarqube-data"
          }
        }
        volume {
          name = "sonarqube-data"
          persistent_volume_claim {
            claim_name = kubernetes_persistent_volume_claim.sonarqube_pvc.metadata[0].name
          }
        }
        restart_policy = "Never"
      }
    }
    backoff_limit = 4
  }
  wait_for_completion = true
  timeouts {
    create = "30m"
  }
  depends_on = [
    kubernetes_persistent_volume_claim.sonarqube_pvc
  ]
} 