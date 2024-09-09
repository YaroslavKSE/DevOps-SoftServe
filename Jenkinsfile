pipeline {
    agent { label 'ec2-linux-4gb' }

    environment {
        // Environment variables remain the same
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

        stage('Verify Application') {
            steps {
                sh '''
                    # Wait for the application to start
                    sleep 30
                    # Check if the application is accessible
                    curl -f http://localhost:3000 || exit 1
                '''
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