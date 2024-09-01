#!/bin/bash

if [ ! -f /vagrant/local_id_rsa.pub ]; then
    echo "Error: local_id_rsa.pub not found in the Vagrant shared folder."
    exit 1
fi

sudo mkdir -p /home/$SFTP_USERNAME/.ssh
sudo cat /vagrant/local_id_rsa.pub >> /home/$SFTP_USERNAME/.ssh/authorized_keys

sudo chmod 700 /home/$SFTP_USERNAME/.ssh
sudo chmod 600 /home/$SFTP_USERNAME/.ssh/authorized_keys
sudo chown -R $SFTP_USERNAME:$SFTP_USERNAME /home/$SFTP_USERNAME/.ssh

echo "Local machine's public key added to $SFTP_USERNAME's authorized_keys."