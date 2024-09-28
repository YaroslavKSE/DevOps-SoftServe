#!/bin/bash

sudo yum update -y
sudo yum install -y docker
sudo service docker start
sudo usermod -a -G docker ec2-user

sudo curl -L "https://github.com/docker/compose/releases/download/1.29.2/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose

# Authenticate Docker with ECR
aws ecr get-login-password --region ${AWS_REGION} | docker login --username AWS --password-stdin ${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com

mkdir -p /home/ec2-user/app
cd /home/ec2-user/app

# Create docker-compose.yml
cat << EOF > docker-compose.yml
${DOCKER_COMPOSE_CONTENT}
EOF

# Create nginx.conf
cat << EOF > nginx.conf
${NGINX_CONF_CONTENT}
EOF

# Start the application
docker-compose up -d