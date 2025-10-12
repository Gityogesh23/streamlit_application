pipeline {
    agent any
    
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
                    // Use withCredentials to correctly load the username and password/token
                    withCredentials([usernamePassword(
                        credentialsId: 'docker-hub-token', // <--- Your Jenkins Credential ID
                        usernameVariable: 'DOCKER_USER',   // <--- Variable for Username
                        passwordVariable: 'DOCKER_PASS'    // <--- Variable for Token/Password
                    )]) {
                        // Login securely using STDIN for the password/token
                        sh "echo \$DOCKER_PASS | docker login -u \$DOCKER_USER --password-stdin"
                        
                        // Perform the push
                        sh 'docker push yogeshpatil23/streamlit-app'
                    }
                    // Credentials variables DOCKER_USER and DOCKER_PASS are automatically cleared here
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
