#!/bin/bash

cat /vagrant/sftp_file_creation_script.sh > /home/vagrant/create_sftp_files.sh

chmod +x /home/vagrant/create_sftp_files.sh

# Add cron job to run the script every 5 minutes
(crontab -l 2>/dev/null; echo "*/5 * * * * /home/vagrant/create_sftp_files.sh") | crontab -

echo "SFTP file creation script setup completed successfully."