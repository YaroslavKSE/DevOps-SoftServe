#!/bin/bash

apt-get update

# Install OpenSSH server and sshpass
apt-get install -y openssh-server sshpass

# Enable password authentication in SSH
sed -i 's/PasswordAuthentication no/PasswordAuthentication yes/' /etc/ssh/sshd_config

systemctl restart ssh

echo "Initial setup completed successfully."