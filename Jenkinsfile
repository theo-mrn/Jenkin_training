pipeline {
    agent any

    stages {
        stage('Hello') {
            steps {
                echo 'Hello Jenkins'
                sh 'echo "Ceci est une commande shell"'
            }
        }
        stage('Build') {
            steps {
                sh 'docker build -t jenkins-training-app .'
            }
        }
    
    }
}
