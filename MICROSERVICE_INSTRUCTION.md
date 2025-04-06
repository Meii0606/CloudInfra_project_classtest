# Sentiment Analysis Application - GKE Deployment Guide 

A comprehensive guide for deploying a microservices-based Sentiment Analysis application on Google Kubernetes Engine (GKE).

<img width="754" alt="Screenshot 2025-02-11 at 02 03 03" src="https://github.com/user-attachments/assets/243f4074-17fa-4f9a-aec6-b169b5df9f31" />


## Architecture

The application consists of three microservices:
- **sa-logic**: Python-based sentiment analysis backend
- **sa-web-app**: Spring Boot web service
- **sa-frontend**: React-based user interface

## Docker Images

All Docker images used in this project are publicly available on Docker Hub:

- Backend (sa-logic): [yimeiw/sentiment-analysis-logic](https://hub.docker.com/r/yimeiw/sentiment-analysis-logic)
- Web App (sa-web-app): [yimeiw/sentiment-analysis-webapp](https://hub.docker.com/r/yimeiw/sentiment-analysis-webapp)
- Frontend (sa-frontend): [yimeiw/sentiment-analysis-frontend](https://hub.docker.com/r/yimeiw/sentiment-analysis-frontend)

## Video Documentation

### Application Demo
[[Demo Video Link](https://drive.google.com/file/d/19Sb4a1r8TYBroUKOQ0S0exlJRQjwS3mT/view?usp=sharing)] - A demonstration of the application running on Google Cloud Platform, showing:
- Application deployment status
- Frontend interface interaction
- Sentiment analysis functionality
- API responses and performance

### Code Walkthrough
[[Code Walkthrough Video Link](https://drive.google.com/file/d/11tlA8o4Ry2NGWCdE1DQo6Kp4Uw7R7zVk/view?usp=drive_link)] - A detailed explanation of:
- Project structure and architecture
- Key code modifications and configurations
- Deployment process and considerations
- Integration between microservices

## Prerequisites

- Google Cloud Platform account
- Google Cloud Shell Editor
- Google Container Registry (GCR) access
- Docker installed

## 1. Set Up Google Kubernetes Engine (GKE)

### 1.1 Create a GKE Cluster

1. Open the Google Cloud Console
2. Navigate to Kubernetes Engine > Clusters
3. Click Create Cluster and choose Standard Cluster
4. Enable all API access for the cluster
5. Connect to the cluster using Cloud Shell:
```bash
gcloud container clusters get-credentials my-first-cluster-1 --zone us-east1-c --project alien-waters-448904-q1
```

## 2. Clone the Source Code

```bash
git clone https://github.com/rinormaloku/k8s-master
cd k8s-master
```

## 3. Deploy sa-logic (Sentiment Analysis Backend)

### 3.1 Build and Push the Image

```bash
cd sa-logic
docker buildx build --platform linux/amd64,linux/arm64 -t yimeiw/sentiment-analysis-logic --push .

# Push to GCR
docker pull yimeiw/sentiment-analysis-logic
docker tag yimeiw/sentiment-analysis-logic gcr.io/alien-waters-448904-q1/sentiment-analysis-logic:latest
docker push gcr.io/alien-waters-448904-q1/sentiment-analysis-logic:latest
```

### 3.2 Deploy to Kubernetes

```bash
cd ../resource-manifests
# Update sa-logic-deployment.yaml with:
# image: gcr.io/alien-waters-448904-q1/sentiment-analysis-logic:latest

kubectl apply -f sa-logic-deployment.yaml
kubectl apply -f service-sa-logic.yaml
```

## 4. Deploy sa-web-app (Spring Boot Web Service)

### 4.1 Build and Push the Image

```bash
cd ../sa-web-app
docker buildx build --platform linux/amd64,linux/arm64 -t yimeiw/sentiment-analysis-webapp --push .

# Push to GCR
docker pull yimeiw/sentiment-analysis-webapp
docker tag yimeiw/sentiment-analysis-webapp gcr.io/alien-waters-448904-q1/sentiment-analysis-webapp:latest
docker push gcr.io/alien-waters-448904-q1/sentiment-analysis-webapp:latest
```

### 4.2 Update Deployment Configuration

Update `sa-web-app-deployment.yaml` to make sure the logic api url aligned with the sa-logic service endpoint:
```yaml
image: gcr.io/alien-waters-448904-q1/sentiment-analysis-webapp:latest
env:
  - name: SA_LOGIC_API_URL
    value: "http://34.118.228.214:80"
```

### 4.3 Deploy to Kubernetes

```bash
kubectl apply -f sa-web-app-deployment.yaml
kubectl apply -f service-sa-web-app.yaml
```

## 5. Deploy sa-frontend (React Frontend)

### 5.1 Update Frontend Configuration

Update `App.js` in src code to make sure it can fetch the web service endpoint:
```javascript
fetch('http://35.237.21.61:80/sentiment', { 
    method: 'POST',
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify({ sentence: this.textField.getValue() })
})
```

### 5.2 Build and Push the Image

```bash
cd ../sa-frontend
docker buildx build --platform linux/amd64,linux/arm64 -t yimeiw/sentiment-analysis-frontend --push .

# Push to GCR
docker pull yimeiw/sentiment-analysis-frontend
docker tag yimeiw/sentiment-analysis-frontend gcr.io/alien-waters-448904-q1/sentiment-analysis-frontend:latest
docker push gcr.io/alien-waters-448904-q1/sentiment-analysis-frontend:latest
```

### 5.3 Deploy to Kubernetes

Update `sa-frontend-deployment.yaml`:
```yaml
image: gcr.io/alien-waters-448904-q1/sentiment-analysis-frontend:latest
```

```bash
kubectl apply -f sa-frontend-deployment.yaml
kubectl apply -f service-sa-frontend.yaml
```
Now we can access the full sentiment analyse application with the frontend service endpoint https://104.196.217.54:80

## References

- https://www.freecodecamp.org/news/learn-kubernetes-in-under-3-hours-a-detailed-guide-to-orchestrating-containers-114ff420e882
- [Building Docker Images on Apple Silicon with buildx](https://docs.docker.com/build/building/multi-platform/)
- [FreeCodeCamp Kubernetes Guide](https://www.freecodecamp.org/news/learn-kubernetes-in-under-3-hours/)
