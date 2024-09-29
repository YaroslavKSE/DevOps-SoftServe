#!/bin/bash

# Update and upgrade packages
sudo apt update && sudo apt upgrade -y

# Install PostgreSQL
wget -qO - https://www.postgresql.org/media/keys/ACCC4CF8.asc | sudo apt-key add -
sudo sh -c 'echo "deb http://apt.postgresql.org/pub/repos/apt $(lsb_release -cs)-pgdg main" > /etc/apt/sources.list.d/pgdg.list'
sudo apt update
sudo apt install -y postgresql-13

# Configure PostgreSQL
sudo -i -u postgres psql -c "CREATE DATABASE schedule_database;"
sudo -i -u postgres psql -c "CREATE USER schedule_user WITH PASSWORD 'schedule_password';"
sudo -i -u postgres psql -c "GRANT ALL PRIVILEGES ON DATABASE schedule_database TO schedule_user;"

# Configure Remote Access
sudo sed -i "s/#listen_addresses = 'localhost'/listen_addresses = '*'/g" /etc/postgresql/13/main/postgresql.conf

# Modify pg_hba.conf for backend access
echo "host    all             all             ${backend_private_ip}/32        md5" | sudo tee -a /etc/postgresql/13/main/pg_hba.conf

# Modify pg_hba.conf for md5 authentication
sudo sed -i "s/local   all             postgres                                peer/local   all             postgres                                md5/g" /etc/postgresql/13/main/pg_hba.conf"
sudo sed -i "s/local   all             all                                     peer/local   all             all                                     md5/g" /etc/postgresql/13/main/pg_hba.conf"

# Restart PostgreSQL
sudo systemctl restart postgresql

# Set environment variables for database restoration
export DB_NAME="schedule_database"
export DB_USER="schedule_user"
export DB_PASSWORD="schedule_password"

# Download the database dump and restore script from S3
aws s3 cp s3://${artifacts_bucket_name}/database.dump /home/ubuntu/database.dump
aws s3 cp s3://${artifacts_bucket_name}/restore_database.sh /home/ubuntu/restore_database.sh

# Make the restore script executable
chmod +x /home/ubuntu/restore_database.sh

# Run the restore script
/home/ubuntu/restore_database.sh local "" /home/ubuntu/database.dump
