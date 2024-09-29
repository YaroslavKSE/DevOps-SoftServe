#!/bin/bash

# Update packages
sudo apt update && sudo apt upgrade -y

# Add the Redis repository
sudo add-apt-repository ppa:redislabs/redis -y
sudo apt update

# Install Redis
sudo apt install -y redis-server

# Configure Redis to bind to all IP addresses
sudo sed -i "s/^bind .*/bind 0.0.0.0/g" /etc/redis/redis.conf

# Restart Redis
sudo systemctl restart redis.service
