#!/bin/bash

# Update packages
sudo apt update && sudo apt upgrade -y

# Install aws cli
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
unzip awscliv2.zip
sudo ./aws/install

# Install session manager:
curl "https://s3.amazonaws.com/session-manager-downloads/plugin/latest/ubuntu_64bit/session-manager-plugin.deb" -o "session-manager-plugin.deb"
sudo dpkg -i session-manager-plugin.deb

# Add the Redis repository
sudo add-apt-repository ppa:redislabs/redis -y
sudo apt update

# Install Redis
sudo apt install -y redis-server

# Start Redis
sudo systemctl start redis-server
sudo systemctl enable redis-server

# Configure Redis to bind to all IP addresses in the private subnet
# Modify the 'bind' directive to bind to 0.0.0.0
sudo sed -i "s/^bind .*/bind 0.0.0.0/g" /etc/redis/redis.conf

# Optionally disable protected mode to allow external access (make sure you handle security appropriately)
sudo sed -i "s/^protected-mode yes/protected-mode no/g" /etc/redis/redis.conf

# Restart Redis
sudo systemctl status redis-server
