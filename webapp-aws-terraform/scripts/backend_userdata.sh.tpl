#!/bin/bash

# Update and upgrade packages
sudo apt update && sudo apt upgrade -y

# Install Java 11
sudo apt install -y openjdk-11-jdk

# Install unzip
sudo apt install unzip

# Install aws cli
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
unzip awscliv2.zip
sudo ./aws/install

# Install session manager:
curl "https://s3.amazonaws.com/session-manager-downloads/plugin/latest/ubuntu_64bit/session-manager-plugin.deb" -o "session-manager-plugin.deb"
sudo dpkg -i session-manager-plugin.deb

# Install Tomcat 9.0.50
wget https://archive.apache.org/dist/tomcat/tomcat-9/v9.0.50/bin/apache-tomcat-9.0.50.tar.gz
sudo mkdir /opt/tomcat
sudo tar xzvf apache-tomcat-9.0.50.tar.gz -C /opt/tomcat --strip-components=1
sudo rm -rf /opt/tomcat/webapps/*

# Set permissions
sudo chown -R ubuntu:ubuntu /opt/tomcat
sudo chmod +x /opt/tomcat/bin/*.sh

# Download the WAR file from S3
aws s3 cp s3://${artifacts_bucket}/app.war /opt/tomcat/webapps/ROOT.war

# Configure Environment Variables
cat <<EOF | sudo tee /opt/tomcat/bin/setenv.sh
export POSTGRES_DB=schedule_database
export POSTGRES_USER=schedule_user
export POSTGRES_PASSWORD=schedule_password
export DATABASE_URL=jdbc:postgresql://${postgres_private_ip}:5432/schedule_database
export REDIS_PROTOCOL=redis
export REDIS_HOST=${redis_private_ip}
export REDIS_PORT=6379
export MONGO_CURRENT_DATABASE=schedules
export DEFAULT_SERVER_CLUSTER=${mongo_private_ip}
EOF

# Start Tomcat
sudo /opt/tomcat/bin/startup.sh
