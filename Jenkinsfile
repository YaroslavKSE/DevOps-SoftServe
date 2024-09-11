pipeline {
    agent { label 'ec2-dynamic-agent' }

    environment {
        POSTGRES_DB = credentials('POSTGRES_DB')
        POSTGRES_USER = credentials('POSTGRES_USER')
        POSTGRES_PASSWORD = credentials('POSTGRES_PASSWORD')
        DATABASE_URL = credentials('DATABASE_URL')
        REDIS_PROTOCOL = credentials('REDIS_PROTOCOL')
        REDIS_HOST = credentials('REDIS_HOST')
        REDIS_PORT = credentials('REDIS_PORT')
        REACT_APP_API_BASE_URL = credentials('REACT_APP_API_BASE_URL')
        MONGO_CURRENT_DATABASE = credentials('MONGO_CURRENT_DATABASE')
        DEFAULT_SERVER_CLUSTER = credentials('DEFAULT_SERVER_CLUSTER')
        AWS_ACCOUNT_ID = credentials('AWS_ACCOUNT_ID')
        AWS_REGION = credentials('AWS_REGION')
        BACKEND_REPO = "${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com/schedule-web-app-backend"
        FRONTEND_REPO = "${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com/schedule-web-app-frontend"
    }

    stages {
        stage('Verify Docker Installation') {
            steps {
                sh '''
                    docker --version
                    docker compose version
                '''
            }
        }

        stage('Checkout') {
            steps {
                checkout scm
            }
        }

        stage('Prepare Environment') {
            steps {
                dir('internship_project') {
                    sh '''
                        echo "POSTGRES_DB=${POSTGRES_DB}" > .env
                        echo "POSTGRES_USER=${POSTGRES_USER}" >> .env
                        echo "POSTGRES_PASSWORD=${POSTGRES_PASSWORD}" >> .env
                        echo "DATABASE_URL=${DATABASE_URL}" >> .env
                        echo "REDIS_PROTOCOL=${REDIS_PROTOCOL}" >> .env
                        echo "REDIS_HOST=${REDIS_HOST}" >> .env
                        echo "REDIS_PORT=${REDIS_PORT}" >> .env
                        echo "REACT_APP_API_BASE_URL=${REACT_APP_API_BASE_URL}" >> .env
                        echo "MONGO_CURRENT_DATABASE=${MONGO_CURRENT_DATABASE}" >> .env
                        echo "DEFAULT_SERVER_CLUSTER=${DEFAULT_SERVER_CLUSTER}" >> .env
                    '''
                }
            }
        }

        stage('Build and Start Application') {
            steps {
                dir('internship_project') {
                    sh 'docker compose up -d --build'
                }
            }
        }

        stage('Tests/Verify Application') {
            steps {
                sh '''
                for i in $(seq 1 12); do
                    if curl -sSf http://localhost:3000 >/dev/null 2>&1; then
                        echo "Application is up!"
                        exit 0
                    fi
                    echo "Attempt $i failed. Waiting..."
                    sleep 10
                done
                echo "Application failed to start"
                exit 1
                '''
            }
        }

        stage('Push Images to ECR') {
            steps {
                script {
                    def tag = sh(script: "date +'%d.%m.%Y'", returnStdout: true).trim()
                    
                    sh '''
                        # Login to AWS ECR
                        aws ecr get-login-password --region ${AWS_REGION} | docker login --username AWS --password-stdin ${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com
                    '''
                    
                    dir('internship_project') {
                        sh """
                            backend_image_id=\$(docker compose images backend -q)
                            docker tag \${backend_image_id} ${BACKEND_REPO}:${tag}
                            docker push ${BACKEND_REPO}:${tag}
                        """
                        
                        sh """
                            frontend_image_id=\$(docker compose images frontend -q)
                            docker tag \${frontend_image_id} ${FRONTEND_REPO}:${tag}
                            docker push ${FRONTEND_REPO}:${tag}
                        """
                    }
                }
            }
        }
    }

    post {
        always {
            dir('internship_project') {
                sh 'docker compose down'
                sh 'rm -f .env'  // Clean up the .env file
            }
        }
    }
}
