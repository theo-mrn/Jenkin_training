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
                sh 'pip install -r requirements.txt'
                sh 'pytest'
            }
        }
        stage('Build') {
            steps {
                sh 'docker build -t jenkins-training-app .'
            }
        }
    
    }
}
