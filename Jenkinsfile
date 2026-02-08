pipeline {
    agent any

    environment {
        // Tag avec le numéro de build Jenkins (ex: 1.0.42)
        IMAGE_NAME = "jenkins-training-app"
        IMAGE_TAG = "${env.BUILD_NUMBER}"
        REGISTRY_USER = "" // Sera rempli par withCredentials
        DOCKER_HUB_USER = "maxwellfaraday" // Change this if different
    }

    stages {
        stage('Hello') {
            steps {
                echo "Building version ${IMAGE_TAG}"
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
                script {
                    sh "docker build -t ${IMAGE_NAME}:${IMAGE_TAG} ."
                    // On garde le tag latest pour faciliter l'usage manuel
                    sh "docker tag ${IMAGE_NAME}:${IMAGE_TAG} ${IMAGE_NAME}:latest"
                }
            }
        }
        stage('Verify') {
            steps {
                // On test l'image taggée spécifiquement pour ce build
                sh "docker run -d -p 5000:5000 --name jenkins-app-${IMAGE_TAG} ${IMAGE_NAME}:${IMAGE_TAG}"
                sh 'sleep 5'
                sh 'curl -f http://localhost:5000'
            }
            post {
                always {
                    sh "docker stop jenkins-app-${IMAGE_TAG} || true"
                    sh "docker rm jenkins-app-${IMAGE_TAG} || true"
                }
            }
        }
        stage('Push') {
            steps {
                withCredentials([usernamePassword(credentialsId: 'docker-hub-credentials', passwordVariable: 'DOCKER_PASSWORD', usernameVariable: 'DOCKER_USERNAME')]) {
                    sh 'echo $DOCKER_PASSWORD | docker login -u $DOCKER_USERNAME --password-stdin'
                    
                    // Push du tag spécifique (pour rollback)
                    sh "docker tag ${IMAGE_NAME}:${IMAGE_TAG} \$DOCKER_USERNAME/${IMAGE_NAME}:${IMAGE_TAG}"
                    sh "docker push \$DOCKER_USERNAME/${IMAGE_NAME}:${IMAGE_TAG}"

                    // Push du tag latest (pour usage courant)
                    sh "docker tag ${IMAGE_NAME}:latest \$DOCKER_USERNAME/${IMAGE_NAME}:latest"
                    sh "docker push \$DOCKER_USERNAME/${IMAGE_NAME}:latest"
                }
            }
        }
        stage('Deploy') {
            steps {
                withCredentials([usernamePassword(credentialsId: 'docker-hub-credentials', passwordVariable: 'DOCKER_PASSWORD', usernameVariable: 'DOCKER_USERNAME')]) {
                    // Nettoyage de l'ancien conteneur de prod
                    sh 'docker stop jenkins-prod || true'
                    sh 'docker rm jenkins-prod || true'

                    // Déploiement de la version spécifique de ce build
                    sh "docker run -d -p 5001:5000 --name jenkins-prod \$DOCKER_USERNAME/${IMAGE_NAME}:${IMAGE_TAG}"
                }
            }
        }
        stage('Deploy Infrastructure') {
            steps {
                withCredentials([usernamePassword(credentialsId: 'aws-credentials', passwordVariable: 'AWS_SECRET_ACCESS_KEY', usernameVariable: 'AWS_ACCESS_KEY_ID')]) {
                    dir('terraform') {
                        // Initialisation
                        sh 'terraform init'
                        
                        // Application et récupération de l'IP
                        sh """
                            terraform apply \
                            -var="docker_image=${env.DOCKER_HUB_USER}/${IMAGE_NAME}" \
                            -var="docker_tag=${IMAGE_TAG}" \
                            -auto-approve
                        """
                        // Sauvegarde de l'IP pour Ansible
                        sh "terraform output -raw public_ip > ../ansible/inventory.ini"
                    }
                }
            }
        }

        stage('Configure with Ansible') {
            steps {
                withCredentials([sshUserPrivateKey(credentialsId: 'ssh-ec2-key', keyFileVariable: 'SSH_KEY')]) {
                    dir('ansible') {
                        // Création d'un inventaire propre
                        sh 'echo "[webserver]" > hosts'
                        sh 'cat inventory.ini >> hosts'
                        
                        // Installation d'Ansible (si nécessaire)
                        sh 'pip install ansible --break-system-packages'

                        // Exécution du playbook
                        // On désactive la vérification de la clé hôte car l'IP change à chaque fois
                        // On ajoute le chemin local au PATH pour trouver l'exécutable ansible-playbook
                        sh """
                            export PATH=\$PATH:~/.local/bin:/var/lib/jenkins/.local/bin
                            export ANSIBLE_HOST_KEY_CHECKING=False
                            ansible-playbook -i hosts playbook.yml \
                            -u ec2-user \
                            --private-key \$SSH_KEY \
                            -e "docker_image=${env.DOCKER_HUB_USER}/${IMAGE_NAME}" \
                            -e "docker_tag=${IMAGE_TAG}"
                        """
                    }
                }
            }
        }   
    }

    post {
        always {
            // Nettoyage du workspace Jenkins pour éviter la saturation disque
            cleanWs()
            // Nettoyage des images locales pour économiser de l'espace (optionnel mais recommandé)
            sh "docker rmi ${IMAGE_NAME}:${IMAGE_TAG} || true"
            sh "docker rmi ${env.DOCKER_HUB_USER}/${IMAGE_NAME}:${IMAGE_TAG} || true"
        }
    }
}
