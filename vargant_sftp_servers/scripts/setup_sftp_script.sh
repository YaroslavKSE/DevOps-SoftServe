#!/bin/bash

cat /vagrant/scripts/sftp_file_creation_script.sh > /home/$SFTP_USERNAME/create_sftp_files.sh

sudo tee /home/$SFTP_USERNAME/.sftp_env << EOF
SFTP_IP_1=$SFTP_IP_1
SFTP_IP_2=$SFTP_IP_2
SFTP_IP_3=$SFTP_IP_3
EOF

chmod +x /home/$SFTP_USERNAME/create_sftp_files.sh

# Add cron job to run the script every 5 minutes
(sudo -u $SFTP_USERNAME crontab -l 2>/dev/null; echo "*/5 * * * * SFTP_USERNAME=$SFTP_USERNAME /home/$SFTP_USERNAME/create_sftp_files.sh") | sudo -u $SFTP_USERNAME crontab -

echo "SFTP file creation script setup completed successfully."