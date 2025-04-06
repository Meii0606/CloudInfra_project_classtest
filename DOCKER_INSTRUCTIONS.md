# Jenkins and SonarQube Docker Setup

This document provides instructions for running the Jenkins and SonarQube containers with their pre-configured state.

## Docker Images

The following Docker images are available on Docker Hub:

- Jenkins: `yyfsss/jenkins:configured`
- SonarQube: `yyfsss/sonarcube:configured`

To pull these images:

```bash
docker pull yyfsss/jenkins:configured
docker pull yyfsss/sonarcube:configured
```

## Data Backups

The backup files for the volumes are available in Google Cloud Storage:

- Jenkins: [jenkins_home_backup.tar.gz](https://storage.googleapis.com/jenkins-sonarqube-backups/jenkins_home_backup.tar.gz) (437MB)
- SonarQube: [sonarqube_data_backup.tar.gz](https://storage.googleapis.com/jenkins-sonarqube-backups/sonarqube_data_backup.tar.gz) (303MB)

Download these files to your local machine before running the containers with the restored volumes:

```bash
# Download using curl
curl -L -o jenkins_home_backup.tar.gz https://storage.googleapis.com/jenkins-sonarqube-backups/jenkins_home_backup.tar.gz
curl -L -o sonarqube_data_backup.tar.gz https://storage.googleapis.com/jenkins-sonarqube-backups/sonarqube_data_backup.tar.gz

# Or download using wget
# wget https://storage.googleapis.com/jenkins-sonarqube-backups/jenkins_home_backup.tar.gz
# wget https://storage.googleapis.com/jenkins-sonarqube-backups/sonarqube_data_backup.tar.gz
```

## Running the Containers


```bash
# Create a network for the containers
docker network create jenkins-sonarqube-network

# Create volumes
docker volume create jenkins_home
docker volume create sonarqube_data

# Restore SonarQube data
docker run --rm -v sonarqube_data:/target -v $(pwd):/backup alpine sh -c "rm -rf /target/* && tar -xzf /backup/sonarqube_data_backup.tar.gz -C /target"

# Restore Jenkins data
docker run --rm -v jenkins_home:/target -v $(pwd):/backup alpine sh -c "rm -rf /target/* && tar -xzf /backup/jenkins_home_backup.tar.gz -C /target"

# Run SonarQube
docker run -d --name sonarqube -p 9000:9000 --network jenkins-sonarqube-network -v sonarqube_data:/opt/sonarqube/data yyfsss/sonarcube:configured

# Run Jenkins
docker run -d --name jenkins -p 8080:8080 -p 50000:50000 --network jenkins-sonarqube-network -v jenkins_home:/var/jenkins_home yyfsss/jenkins:configured
```

## Access the Services

- Jenkins: http://localhost:8080
- SonarQube: http://localhost:9000

## Important Note

When using Jenkins with SonarQube, make sure to use `sonarqube` as the hostname in your SonarQube URL configuration, not `localhost`. This is because the containers are on the same Docker network.

Example:
```
sonar-scanner -Dsonar.host.url=http://sonarqube:9000 ...
``` 