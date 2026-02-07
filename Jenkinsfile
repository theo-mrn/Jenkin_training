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
                sh '''
                    python3 -m venv venv
                    . venv/bin/activate
                    pip install -r requirements.txt
                    pytest
                '''
            }
        }
        stage('Build') {
            steps {
                sh 'docker build -t jenkins-training-app .'
            }
        }
    
    }
}
