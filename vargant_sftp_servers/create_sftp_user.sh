#!/bin/bash

sudo useradd -m -d /home/$SFTP_USERNAME -s /bin/bash $SFTP_USERNAME

echo "$SFTP_USERNAME:$SFTP_PASSWORD" | sudo chpasswd

sudo mkdir -p /home/$SFTP_USERNAME/sftp

sudo chown $SFTP_USERNAME:$SFTP_USERNAME /home/$SFTP_USERNAME/sftp

sudo chmod 755 /home/$SFTP_USERNAME
sudo chmod 700 /home/$SFTP_USERNAME/sftp

echo "SFTP user created successfully."