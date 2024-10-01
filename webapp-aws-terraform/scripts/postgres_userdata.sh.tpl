#!/bin/bash

# Update and upgrade packages
sudo apt update && sudo apt upgrade -y

# Install unzip
sudo apt install unzip

# Install aws cli
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
unzip awscliv2.zip
sudo ./aws/install

# Install session manager:
curl "https://s3.amazonaws.com/session-manager-downloads/plugin/latest/ubuntu_64bit/session-manager-plugin.deb" -o "session-manager-plugin.deb"
sudo dpkg -i session-manager-plugin.deb

# Install PostgreSQL
wget -qO - https://www.postgresql.org/media/keys/ACCC4CF8.asc | sudo apt-key add -
sudo sh -c 'echo "deb http://apt.postgresql.org/pub/repos/apt $(lsb_release -cs)-pgdg main" > /etc/apt/sources.list.d/pgdg.list'
sudo apt update
sudo apt install -y postgresql-13

# Start and enable Postgresql
sudo systemctl start postgresql
sudo systemctl enable postgresql

# Configure PostgreSQL
sudo -i -u postgres psql -c "CREATE DATABASE schedule_database;"
sudo -i -u postgres psql -c "CREATE USER schedule_user WITH PASSWORD 'schedule_password';"
sudo -i -u postgres psql -c "GRANT ALL PRIVILEGES ON DATABASE schedule_database TO schedule_user;"

# Configure Remote Access
sudo sed -i "s/#listen_addresses = 'localhost'/listen_addresses = '*'/g" /etc/postgresql/13/main/postgresql.conf

# Modify pg_hba.conf for backend access
echo "host    all             all             ${allowed_cidr}        md5" | sudo tee -a /etc/postgresql/13/main/pg_hba.conf

# Modify pg_hba.conf for md5 authentication
sudo sed -i "s/local   all             postgres                                peer/local   all             postgres                                md5/g" /etc/postgresql/13/main/pg_hba.conf"
sudo sed -i "s/local   all             all                                     peer/local   all             all                                     md5/g" /etc/postgresql/13/main/pg_hba.conf"

sudo sed -i "s/local\s\+all\s\+all\s\+peer/local all all md5/" /etc/postgresql/13/main/pg_hba.conf

# Restart PostgreSQL
sudo systemctl restart postgresql

# Set environment variables for database restoration
export DB_NAME="schedule_database"
export DB_USER="schedule_user"
export DB_PASSWORD="schedule_password"

# Download the database dump and restore script from S3
aws s3 cp s3://${artifacts_bucket}/database.dump /home/ubuntu/database.dump
aws s3 cp s3://${artifacts_bucket}/restore_database.sh /home/ubuntu/restore_database.sh

# Make the restore script executable
chmod +x /home/ubuntu/restore_database.sh

# Run the restore script
/home/ubuntu/restore_database.sh local "" /home/ubuntu/database.dump
