pipeline {
    agent any

    stages {
        stage('Hello') {
            steps {
                echo 'Hello Jenkins'
                sh 'echo "Ceci est une commande shell"'
            }
        }
        stage('Test') {
            steps {
                sh 'pip install -r requirements.txt --break-system-packages'
                sh 'python3 -m pytest'
            }
        }
        stage('Build') {
            steps {
                sh 'docker build -t jenkins-training-app .'
            }
        }
        stage('Verify') {
            steps {
                sh 'docker run -d -p 5000:5000 --name jenkins-app jenkins-training-app'
                sh 'sleep 5'
                sh 'curl -f http://localhost:5000'
            }
            post {
                always {
                    sh 'docker stop jenkins-app || true'
                    sh 'docker rm jenkins-app || true'
                }
            }
        }
        stage('Push') {
            steps {
                withCredentials([usernamePassword(credentialsId: 'docker-hub-credentials', passwordVariable: 'DOCKER_PASSWORD', usernameVariable: 'DOCKER_USERNAME')]) {
                    sh 'echo $DOCKER_PASSWORD | docker login -u $DOCKER_USERNAME --password-stdin'
                    sh 'docker tag jenkins-training-app $DOCKER_USERNAME/jenkins-training-app:latest'
                    sh 'docker push $DOCKER_USERNAME/jenkins-training-app:latest'
                }
            }
        }
    
        stage('Deploy') {
            steps {
                withCredentials([usernamePassword(credentialsId: 'docker-hub-credentials', passwordVariable: 'DOCKER_PASSWORD', usernameVariable: 'DOCKER_USERNAME')]) {
                    sh 'docker stop jenkins-prod || true'
                    sh 'docker rm jenkins-prod || true'
                    sh 'docker pull $DOCKER_USERNAME/jenkins-training-app:latest'
                    sh 'docker run -d -p 5001:5000 --name jenkins-prod $DOCKER_USERNAME/jenkins-training-app:latest'
                }
            }
        }
    
    }
}
