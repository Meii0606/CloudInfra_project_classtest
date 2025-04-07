# Storage class for Persistent Volumes
resource "kubernetes_storage_class" "jenkins_sonarqube_sc" {
  metadata {
    name = "jenkins-sonarqube-sc"
  }
  storage_provisioner = "kubernetes.io/gce-pd"
  parameters = {
    type = "pd-standard"
  }
  reclaim_policy      = "Retain"
  volume_binding_mode = "Immediate"
  
  depends_on = [
    null_resource.dependency,
    module.gke_auth
  ]
}

# Create namespace
resource "kubernetes_namespace" "jenkins_sonarqube" {
  metadata {
    name = "jenkins-sonarqube"
  }
}

# Persistent Volume Claims
resource "kubernetes_persistent_volume_claim" "jenkins_pvc" {
  metadata {
    name      = "jenkins-pvc"
    namespace = kubernetes_namespace.jenkins_sonarqube.metadata[0].name
  }
  spec {
    access_modes = ["ReadWriteOnce"]
    resources {
      requests = {
        storage = "20Gi"
      }
    }
    storage_class_name = kubernetes_storage_class.jenkins_sonarqube_sc.metadata[0].name
  }
  
  timeouts {
    create = "30m"
  }
}

resource "kubernetes_persistent_volume_claim" "sonarqube_pvc" {
  metadata {
    name      = "sonarqube-pvc"
    namespace = kubernetes_namespace.jenkins_sonarqube.metadata[0].name
  }
  spec {
    access_modes = ["ReadWriteOnce"]
    resources {
      requests = {
        storage = "10Gi"
      }
    }
    storage_class_name = kubernetes_storage_class.jenkins_sonarqube_sc.metadata[0].name
  }
  
  timeouts {
    create = "30m"
  }
}

# Create a Kubernetes Service for Jenkins
resource "kubernetes_service" "jenkins" {
  metadata {
    name      = "jenkins"
    namespace = kubernetes_namespace.jenkins_sonarqube.metadata[0].name
  }
  spec {
    selector = {
      app = "jenkins"
    }
    port {
      name        = "http"
      port        = 8080
      target_port = 8080
    }
    port {
      name        = "jnlp"
      port        = 50000
      target_port = 50000
    }
    type = "LoadBalancer"
  }
  
  timeouts {
    create = "15m"
  }
}

# Create a Kubernetes Service for SonarQube
resource "kubernetes_service" "sonarqube" {
  metadata {
    name      = "sonarqube"
    namespace = kubernetes_namespace.jenkins_sonarqube.metadata[0].name
  }
  spec {
    selector = {
      app = "sonarqube"
    }
    port {
      name        = "http"
      port        = 9000
      target_port = 9000
    }
    type = "LoadBalancer"
  }
  
  timeouts {
    create = "15m"
  }
}

# Create a Kubernetes Deployment for Jenkins
resource "kubernetes_deployment" "jenkins" {
  metadata {
    name      = "jenkins"
    namespace = kubernetes_namespace.jenkins_sonarqube.metadata[0].name
  }
  
  depends_on = [
    kubernetes_persistent_volume_claim.jenkins_pvc
  ]
  
  spec {
    replicas = 1
    selector {
      match_labels = {
        app = "jenkins"
      }
    }
    template {
      metadata {
        labels = {
          app = "jenkins"
        }
      }
      spec {
        container {
          name  = "jenkins"
          image = "yyfsss/jenkins:configured"
          port {
            container_port = 8080
          }
          port {
            container_port = 50000
          }
          volume_mount {
            name       = "jenkins-home"
            mount_path = "/var/jenkins_home"
          }
          resources {
            limits = {
              cpu    = "1"
              memory = "2Gi"
            }
            requests = {
              cpu    = "500m"
              memory = "1Gi"
            }
          }
        }
        volume {
          name = "jenkins-home"
          persistent_volume_claim {
            claim_name = kubernetes_persistent_volume_claim.jenkins_pvc.metadata[0].name
          }
        }
      }
    }
  }
}

# Create a Kubernetes Deployment for SonarQube
resource "kubernetes_deployment" "sonarqube" {
  metadata {
    name      = "sonarqube"
    namespace = kubernetes_namespace.jenkins_sonarqube.metadata[0].name
  }
  
  depends_on = [
    kubernetes_persistent_volume_claim.sonarqube_pvc
  ]
  
  spec {
    replicas = 1
    selector {
      match_labels = {
        app = "sonarqube"
      }
    }
    template {
      metadata {
        labels = {
          app = "sonarqube"
        }
      }
      spec {
        container {
          name  = "sonarqube"
          image = "yyfsss/sonarcube:configured"
          port {
            container_port = 9000
          }
          volume_mount {
            name       = "sonarqube-data"
            mount_path = "/opt/sonarqube/data"
          }
          resources {
            limits = {
              cpu    = "1"
              memory = "2Gi"
            }
            requests = {
              cpu    = "500m"
              memory = "1Gi"
            }
          }
        }
        volume {
          name = "sonarqube-data"
          persistent_volume_claim {
            claim_name = kubernetes_persistent_volume_claim.sonarqube_pvc.metadata[0].name
          }
        }
      }
    }
  }
} 