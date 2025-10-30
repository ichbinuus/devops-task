#!/bin/bash
set -e

PROJECT_ID="rama17-05-2020"
REGION="asia-south1"
JENKINS_NS="jenkins"
GSA="jenkins-ci"
KSA="jenkins"

echo "Creating Google Service Account (GSA)..."
gcloud iam service-accounts create $GSA --display-name "Jenkins CI Service Account" || true

echo "Granting IAM roles..."
gcloud projects add-iam-policy-binding $PROJECT_ID \
  --member="serviceAccount:$GSA@$PROJECT_ID.iam.gserviceaccount.com" \
  --role="roles/artifactregistry.writer"

gcloud projects add-iam-policy-binding $PROJECT_ID \
  --member="serviceAccount:$GSA@$PROJECT_ID.iam.gserviceaccount.com" \
  --role="roles/container.developer"

echo "Creating Kubernetes Service Account (KSA)..."
kubectl -n $JENKINS_NS create serviceaccount $KSA --dry-run=client -o yaml | kubectl apply -f -

echo "Binding GSA to KSA..."
gcloud iam service-accounts add-iam-policy-binding $GSA@$PROJECT_ID.iam.gserviceaccount.com \
  --member="serviceAccount:$PROJECT_ID.svc.id.goog[$JENKINS_NS/$KSA]" \
  --role="roles/iam.workloadIdentityUser"

kubectl -n $JENKINS_NS annotate serviceaccount $KSA \
  iam.gke.io/gcp-service-account=$GSA@$PROJECT_ID.iam.gserviceaccount.com --overwrite

echo "✅ Workload Identity setup complete!"

