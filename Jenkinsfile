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
        BACKEND_VERSION_FILE = 'internship_project/src/version.txt'
        FRONTEND_VERSION_FILE = 'internship_project/frontend/version.txt'
        GIT_CREDS = credentials('GIT_CREDENTIALS')
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

        stage('Verify[Test] Application') {
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


        stage('Load Pipeline Functions') {
            steps {
                script {
                    pipelineFunctions = load 'jenkins/pipeline_functions.groovy'
                }
            }
        }

        stage('Determine Changes and Versions') {
            steps {
                script {
                    env.BACKEND_CHANGED = sh(script: "git diff --name-only HEAD^ HEAD | grep '^internship_project/src'", returnStatus: true) == 0
                    env.FRONTEND_CHANGED = sh(script: "git diff --name-only HEAD^ HEAD | grep '^internship_project/frontend'", returnStatus: true) == 0

                    def versionChange = pipelineFunctions.determineVersionChange()

                    env.NEW_BACKEND_VERSION = env.BACKEND_CHANGED ? pipelineFunctions.updateComponentVersion('Backend', env.BACKEND_VERSION_FILE, env.BACKEND_CHANGED, versionChange) : readFile(env.BACKEND_VERSION_FILE).trim()
                    env.NEW_FRONTEND_VERSION = env.FRONTEND_CHANGED ? pipelineFunctions.updateComponentVersion('Frontend', env.FRONTEND_VERSION_FILE, env.FRONTEND_CHANGED, versionChange) : readFile(env.FRONTEND_VERSION_FILE).trim()

                    def commitMessage = []
                    if (env.BACKEND_CHANGED) {
                        commitMessage.add("Backend ${env.NEW_BACKEND_VERSION}")
                    }
                    if (env.FRONTEND_CHANGED) {
                        commitMessage.add("Frontend ${env.NEW_FRONTEND_VERSION}")
                    }

                    if (commitMessage) {
                        withCredentials([
                            string(credentialsId: 'github-versioning-token', variable: 'GITHUB_TOKEN'),
                            string(credentialsId: 'jenkins-email', variable: 'JENKINS_EMAIL')
                        ]) {
                            sh """
                                git config user.email "\${JENKINS_EMAIL}"
                                git config user.name "Jenkins"
                                git add ${env.BACKEND_CHANGED ? env.BACKEND_VERSION_FILE : ''} ${env.FRONTEND_CHANGED ? env.FRONTEND_VERSION_FILE : ''}
                                git commit -m "Update versions: ${commitMessage.join(', ')}"
                                git push https://x-access-token:${GITHUB_TOKEN}@github.com/your-repo-url.git HEAD:${env.GIT_BRANCH}
                            """
                        }
                        echo "Pushed version updates: ${commitMessage.join(', ')}"
                    } else {
                        echo "No changes detected. Skipping version update commit."
                    }
                }
            }
        }

        stage('Push Images') {
            steps {
                script {
                    sh '''
                        # Login to AWS ECR
                        aws ecr get-login-password --region ${AWS_REGION} | docker login --username AWS --password-stdin ${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com
                    '''
                    
                    dir('internship_project') {
                        if (env.BACKEND_CHANGED == 'true') {
                            sh """
                                backend_image_id=\$(docker compose images backend -q)
                                docker tag \${backend_image_id} ${BACKEND_REPO}:${env.NEW_VERSION}
                                docker push ${BACKEND_REPO}:${env.NEW_VERSION}
                            """
                        } else {
                            echo "No changes detected in backend. Skipping backend build and push."
                        }
                        
                        if (env.FRONTEND_CHANGED == 'true') {
                            sh """
                                frontend_image_id=\$(docker compose images frontend -q)
                                docker tag \${frontend_image_id} ${FRONTEND_REPO}:${env.NEW_VERSION}
                                docker push ${FRONTEND_REPO}:${env.NEW_VERSION}
                            """
                        } else {
                            echo "No changes detected in frontend. Skipping frontend build and push."
                        }
                    }
                }
            }
        }
    }

    post {
        always {
            dir('internship_project') {
                sh 'docker compose down'
                sh 'rm -f .env'
            }
        }
    }
}
