pipeline {
    agent any

    environment {
        DOCKER_CREDENTIALS = credentials('docker-hub-token') // your Jenkins credentials ID
    }

    stages {
        stage('Checkout') {
            steps {
                git 'https://github.com/Gityogesh23/streamlit_application.git'
            }
        }

        stage('Build Docker Image') {
            steps {
                sh 'docker build -t yogeshpatil23/streamlit-app .'
            }
        }

        stage('Push Docker Image') {
            steps {
                script {
                    // Login using Docker token securely
                    sh "echo \$DOCKER_CREDENTIALS_PSW | docker login -u \$DOCKER_CREDENTIALS_USR --password-stdin"
                    sh 'docker push yogeshpatil23/streamlit-app'
                }
            }
        }

        stage('Run Docker Container') {
            steps {
                sh 'docker rm -f streamlit-container01 || true'
                sh 'docker run -d --name streamlit-container01 -p 8501:8501 yogeshpatil23/streamlit-app'
            }
        }
    }
}
