#!/bin/bash

# Update packages
sudo apt update && sudo apt upgrade -y

# Install Node.js 18
curl -fsSL https://deb.nodesource.com/setup_18.x | sudo -E bash -
sudo apt install -y nodejs

# Navigate to home directory
cd /home/ubuntu

# Download frontend artifacts from S3
aws s3 cp s3://${artifacts_bucket}/frontend.tar.gz ./frontend.tar.gz

# Extract the frontend application
tar -xzvf frontend.tar.gz

# Install dependencies
cd frontend
npm install

# Configure Environment Variables
echo "REACT_APP_API_BASE_URL=http://${backend_private_ip}:8080" > .env

# Start the application (you may want to run it as a background process or use a process manager)
npm start &
