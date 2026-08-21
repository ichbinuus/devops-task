pipeline {

    agent any

    environment {
        PROJECT_ID = 'sisl-internal-alloydb-testing'
        REGION = 'asia-south1'
        REPOSITORY = 'devops-repo'
        IMAGE_NAME = 'devops-app'

        IMAGE = "${REGION}-docker.pkg.dev/${PROJECT_ID}/${REPOSITORY}/${IMAGE_NAME}"
    }

    stages {

        stage('Checkout') {
            steps {
                checkout scm
            }
        }

        stage('Install Dependencies') {
            steps {
                sh 'npm ci'
            }
        }

        stage('Test') {
            steps {
                sh 'npm test'
            }
        }

        stage('Docker Build') {
            steps {
                sh '''
                    docker build \
                    -t ${IMAGE}:${BUILD_NUMBER} \
                    .
                '''
            }
        }

        stage('Push to Artifact Registry') {
            steps {
                sh '''
                    docker push ${IMAGE}:${BUILD_NUMBER}
                '''
            }
        }

        stage('Deploy to Cloud Run') {
            steps {
                sh '''
                    gcloud run deploy ${IMAGE_NAME} \
                      --image=${IMAGE}:${BUILD_NUMBER} \
                      --region=${REGION} \
                      --project=${PROJECT_ID} \
                      --platform=managed \
                      --quiet
                '''
            }
        }

    }

    post {

        success {
            echo 'Pipeline completed successfully.'
            echo "Deployed Docker image: ${IMAGE}:${BUILD_NUMBER}"
        }

        failure {
            echo 'Pipeline failed. Check the stage logs.'
        }

    }
}