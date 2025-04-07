output "kubernetes_cluster_name" {
  value       = google_container_cluster.jenkins_sonarqube_cluster.name
  description = "GKE Cluster Name"
}

output "jenkins_service_external_ip" {
  value       = kubernetes_service.jenkins.status.0.load_balancer.0.ingress.0.ip
  description = "External IP address of the Jenkins service"
  depends_on  = [kubernetes_service.jenkins]
}

output "sonarqube_service_external_ip" {
  value       = kubernetes_service.sonarqube.status.0.load_balancer.0.ingress.0.ip
  description = "External IP address of the SonarQube service"
  depends_on  = [kubernetes_service.sonarqube]
}

output "jenkins_url" {
  value       = "http://${kubernetes_service.jenkins.status.0.load_balancer.0.ingress.0.ip}:8080"
  description = "URL to access Jenkins"
  depends_on  = [kubernetes_service.jenkins]
}

output "sonarqube_url" {
  value       = "http://${kubernetes_service.sonarqube.status.0.load_balancer.0.ingress.0.ip}:9000"
  description = "URL to access SonarQube"
  depends_on  = [kubernetes_service.sonarqube]
}

output "important_note" {
  value = "When using Jenkins with SonarQube, make sure to use 'sonarqube' as the hostname in your SonarQube URL configuration within Jenkins, not the external IP. This is because the containers communicate within the Kubernetes network."
} 