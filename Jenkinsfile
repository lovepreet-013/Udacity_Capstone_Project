pipeline {
    agent any
    environment {
        DOCKER_IMAGE_NAME = "lovepreet13/flaskapp"
    }
    stages {
        stage('Testing out git repo') {
            steps {
                echo 'Checkout...'
                checkout scm
            }
        }
        stage('Testing environment') {
            steps {
                echo 'Testing environment...'
                sh 'git --version'
                echo "Branch: ${env.GIT_BRANCH}"
                sh 'docker -v'
                sh 'kubectl version --client'
            }
        }
        stage('Install Dependencies') {
            steps {
                echo 'Installing dependencies...'
                sh 'python3 -m venv venv'
                sh '. venv/bin/activate'
                sh 'make install'
                sh 'sudo wget -O /bin/hadolint https://github.com/hadolint/hadolint/releases/download/v1.16.3/hadolint-Linux-x86_64 && sudo chmod +x /bin/hadolint'
            }
        }
        stage('Lint Test') {
            steps {
                sh '. venv/bin/activate'
                sh 'make lint'
            }
        }
        stage('Build Docker Image') {
            steps {
                echo 'Building Docker image...'
                withCredentials([usernamePassword(credentialsId: 'dockerhub', passwordVariable: 'dockerhubPassword', usernameVariable: 'dockerhubUser')]) {
                    sh "docker login -u ${env.dockerHubUser} -p ${env.dockerHubPassword}"
                    sh "docker builder build -t ${env.DOCKER_IMAGE_NAME} ."
                    sh "docker push ${env.DOCKER_IMAGE_NAME}"
                }
            }
        }
        stage('Deployment') {
            steps {
                sh "kubectl create deployment kubernetes-flaskapp --image=${env.DOCKER_IMAGE_NAME}"
                sh "kubectl get deployments"
                sh "kubectl get pods"
                sh "kubectl describe pods"
//                sh "export POD_NAME=$(kubectl get pods -o go-template --template '{{range .items}}{{.metadata.name}}{{"\n"}}{{end}}')"
//                echo "Name of the Pod: ${env.POD_NAME}"
//                sh "kubectl port-forward ${env.POD_NAME} 8080:80"
            }
        }
    }
    post {
        cleanup {
            echo 'Cleaning up...'
            sh "docker system prune -f"
        }
    }
}
