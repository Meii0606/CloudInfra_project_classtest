This project first deploy a sentiment analysis microservice with GKE, the use Terraform configuration deploys a Jenkins and SonarQube pipeline onto Google Kubernetes Engine (GKE) using the pre-configured Docker images to check the static code of microservice here. Also, using terraform set up a hadoop cluster on Google Dataproc to handle the hadoop task.

## Prerequisites

- Google Cloud Platform account
- Google Cloud SDK installed and configured
- Terraform installed locally
- Access to the Google Cloud Storage bucket containing the backups (or you can modify the scripts to download from elsewhere)

## Setup

1. Clone this repository and follow the `DOCKER_INSTRUCTIONS.md` to run your containers.
2. Spereately navigate to the jenkins-sonarqube & hadoop directory, add your GCP account credentials.json file.
3. Navigate to the `jenkins-sonarqube/terraform.tfvars` file update your GCP project ID:

```
project_id = "your-gcp-project-id"
region     = "us-central1"  # or your preferred region
```

4. Navigate to the `hadoop/terraform.tfvars` & `hadoop/variables.tf` file update your GCP project ID and service account:

```
project_id = "your-gcp-project-id"
```

```
variable "service_account" {
  type        = string
  description = "Service Account"
  default     = "388250803076-compute@developer.gserviceaccount.com" # align with credentials
}
```

4. Initialize Terraform under jenkins-sonarqube & hadoop folder

```bash
terraform init
terraform plan
terraform apply
```

5. Once the deployment is complete, the output will provide the URLs to access Jenkins and SonarQube and your dataproc master & worker ip:

```
dataproc_master_ip = "10.142.15.228"
dataproc_worker1_ip = "10.142.15.229"
dataproc_worker2_ip = "10.142.15.227"
```

```
important_note = "When using Jenkins with SonarQube, make sure to use 'sonarqube' as the hostname in your SonarQube URL configuration within Jenkins, not the external IP. This is because the containers communicate within the Kubernetes network."
jenkins_service_external_ip = "34.48.151.223"
jenkins_url = "http://34.48.151.223:8080"
kubernetes_cluster_name = "jenkins-sonarqube-cluster"
sonarqube_service_external_ip = "34.48.104.105"
sonarqube_url = "http://34.48.104.105:9000"
```

## Accessing the Jenkins and SonarQube Services

- Jenkins will be available at: http://<jenkins_external_ip>:8080
- SonarQube will be available at: http://<sonarqube_external_ip>:9000

## Important Note

When using Jenkins with SonarQube, make sure to use `sonarqube` as the hostname in your SonarQube URL configuration within Jenkins, not the external IP. This is because the containers communicate within the Kubernetes network.

Example in Jenkins pipeline:
```
sonar-scanner -Dsonar.host.url=http://sonarqube:9000 ...
```
6. Once you


## Cleanup

To remove all resources created by this Terraform configuration:

```bash
terraform destroy
```

## Architecture

This deployment:

1. Creates a GKE cluster in your specified GCP project and region
2. Deploys the pre-configured Jenkins and SonarQube containers
3. Sets up persistent storage for both services
4. Initializes the storage with backup data from Google Cloud Storage
5. Exposes both services with external IPs for access 

## Reference
- Farag, Mohamed. 14-848 Cloud Infrastructure Course Lectures and Slides. Carnegie Mellon University, 2024.

- TutorialEdge. "Hadoop Cluster Setup in Docker: Running Hadoop on Docker." YouTube, 2024, www.youtube.com/watch?v=SN2VDCBzSlE&list=TLPQMDkxMDIwMjRlk_YMchn30w&index=1. Accessed 9 Oct. 2024.

- BDE2020. Hadoop DataNode Docker Image, Version 2.0.0-hadoop3.2.1-java8. Docker Hub, hub.docker.com/r/bde2020/hadoop-datanode. Accessed 9 Oct. 2024.

- SonarSource. “Global Setup for Jenkins Integration.” *SonarQube Documentation*, 2024, https://docs.sonarsource.com/sonarqube/10.6/analyzing-source-code/ci-integration/jenkins-integration/global-setup/. Accessed 9 Oct. 2024.
  
- DevOpsSchool. "How to Execute SonarQube Scanner Using Jenkins Pipeline." *DevOpsSchool*, 2024, https://www.devopsschool.com/blog/how-to-execute-sonarqube-scanner-using-jenkins-pipeline/. Accessed 9 Oct. 2024.

- DigitalOcean. "How to Automate Jenkins Setup with Docker and Jenkins Configuration as Code." *DigitalOcean Community Tutorials*, 2024, https://www.digitalocean.com/community/tutorials/how-to-automate-jenkins-setup-with-docker-and-jenkins-configuration-as-code. Accessed 9 Oct. 2024.
