#!/bin/bash
set -e

PROJECT_ID="rama17-05-2020"
REGION="asia-south1"
CLUSTER="cluster"
AR_REPO="registry"
APP_NS="devops-task"
JENKINS_NS="jenkins"

echo "Getting cluster credentials..."
gcloud container clusters get-credentials $CLUSTER --region $REGION --project $PROJECT_ID

echo "Creating namespaces..."
kubectl create ns $APP_NS --dry-run=client -o yaml | kubectl apply -f -
kubectl create ns $JENKINS_NS --dry-run=client -o yaml | kubectl apply -f -

echo "Creating Artifact Registry..."
gcloud artifacts repositories create $AR_REPO \
  --repository-format=docker \
  --location=$REGION \
  --description="Docker images for devops-task app" || echo "Repository already exists"

echo "✅ GKE + Artifact Registry setup complete!"

