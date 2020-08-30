pipeline {
    agent any
    environment {
        DOCKER_IMAGE_NAME = "lovepreet013/flaskapp"
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
                sh 'wget -O /bin/hadolint https://github.com/hadolint/hadolint/releases/download/v1.16.3/hadolint-Linux-x86_64 &&\chmod +x /bin/hadolint'
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
        stage('CanaryDeploy') {
            when {
                branch 'master'
            }
            environment { 
                CANARY_REPLICAS = 1
            }
            steps {
                kubernetesDeploy(
                    kubeconfigId: 'kubeconfig',
                    configs: 'portfolio-deploy-canary.yaml',
                    enableConfigSubstitution: true
                )
            }
        }
        stage('DeployToProduction') {
            when {
                branch 'master'
            }
            environment { 
                CANARY_REPLICAS = 0
            }
            steps {
                input 'Deploy to Production?'
                milestone(1)
                kubernetesDeploy(
                    kubeconfigId: 'kubeconfig',
                    configs: 'portfolio-deploy-canary.yaml',
                    enableConfigSubstitution: true
                )
                kubernetesDeploy(
                    kubeconfigId: 'kubeconfig',
                    configs: 'portfolio-deploy.yaml',
                    enableConfigSubstitution: true
                )
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