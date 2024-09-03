#!/bin/bash

if [ ! -f /home/$SFTP_USERNAME/.ssh/id_rsa ]; then
    sudo -u $SFTP_USERNAME ssh-keygen -t rsa -N "" -f /home/$SFTP_USERNAME/.ssh/id_rsa
    echo "SSH key generated for $SFTP_USERNAME."
else
    echo "SSH key already exists for $SFTP_USERNAME."
fi

sudo chmod 700 /home/$SFTP_USERNAME/.ssh
sudo chmod 600 /home/$SFTP_USERNAME/.ssh/id_rsa
sudo chmod 644 /home/$SFTP_USERNAME/.ssh/id_rsa.pub
sudo chown -R $SFTP_USERNAME:$SFTP_USERNAME /home/$SFTP_USERNAME/.ssh

echo "SSH key generation and permission setting complete for $SFTP_USERNAME."