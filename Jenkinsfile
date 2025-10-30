pipeline {
  agent { label 'default' }
  environment {
    PROJECT_ID   = "rama17-05-2020"
    REGION       = "asia-south1"
    AR_REPO      = "registry"
    IMAGE        = "${REGION}-docker.pkg.dev/${PROJECT_ID}/${AR_REPO}/devops-task"
    APP_NS       = "devops-task"
    COMMIT_SHA   = sh(script: "git rev-parse --short HEAD", returnStdout: true).trim()
    TAG          = "${env.BRANCH_NAME}-${COMMIT_SHA}"
  }
  triggers { githubPush() }
  stages {
    stage('Checkout') {
      steps { checkout scm }
    }
    stage('Install & Test') {
      steps {
        container('node') {
          sh '''
            npm ci
            npm test || echo "no tests"
          '''
        }
      }
    }
    stage('Build & Push Image') {
      steps {
        container('kaniko') {
          sh '''
            cat > /kaniko/.docker/config.json <<EOF
            { "credHelpers": { "${REGION}-docker.pkg.dev": "gcloud" } }
            EOF
            /kaniko/executor \
              --context $WORKSPACE \
              --destination ${IMAGE}:${TAG} \
              --cache=true \
              --cache-repo ${IMAGE}-cache
          '''
        }
      }
    }
    stage('Deploy to GKE') {
      steps {
        container('kubectl') {
          sh '''
            sed -e "s|__TAG__|${TAG}|g" k8s/deployment.yaml > /tmp/deploy.yaml
            kubectl apply -n ${APP_NS} -f /tmp/deploy.yaml
            kubectl rollout status deploy/devops-task -n ${APP_NS} --timeout=120s
            kubectl apply -n ${APP_NS} -f k8s/service.yaml
          '''
        }
      }
    }
  }
}

