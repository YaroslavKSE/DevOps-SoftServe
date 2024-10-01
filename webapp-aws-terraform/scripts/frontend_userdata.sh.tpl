#!/bin/bash

# Update packages
sudo apt update && sudo apt upgrade -y

# Install unzip and nginx
sudo apt install -y unzip nginx

# Install aws cli
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
unzip awscliv2.zip
sudo ./aws/install

# Install session manager:
curl "https://s3.amazonaws.com/session-manager-downloads/plugin/latest/ubuntu_64bit/session-manager-plugin.deb" -o "session-manager-plugin.deb"
sudo dpkg -i session-manager-plugin.deb

# Install Node.js 18
curl -fsSL https://deb.nodesource.com/setup_18.x | sudo -E bash -
sudo apt install -y nodejs npm

# Navigate to home directory
cd /home/ubuntu

# Create directory for frontend artifacts
mkdir frontend

# Download frontend artifacts from S3
aws s3 cp s3://${artifacts_bucket}/build.tar.gz ./build.tar.gz

# Extract the frontend application
tar -xzvf build.tar.gz -C frontend

# Remove default Nginx web content
sudo rm -rf /var/www/html/*

# Copy frontend build files to Nginx web root
sudo cp -r frontend/build/* /var/www/html/

# Download the Nginx configuration template from S3
aws s3 cp s3://${artifacts_bucket}/nginx.conf.tpl ./nginx.conf.tpl

# Replace placeholder with actual backend private IP
sed "s/{{BACKEND_PRIVATE_IP}}/${backend_private_ip}/g" nginx.conf.tpl > nginx.conf

# Move the processed configuration file to Nginx directory
sudo mv nginx.conf /etc/nginx/sites-available/default

# Reload Nginx to apply changes
sudo systemctl reload nginx