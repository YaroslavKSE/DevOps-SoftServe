#!/bin/bash

# Array of all VM IPs
vms=("$SFTP_IP_1" "$SFTP_IP_2" "$SFTP_IP_3")

copy_ssh_key() {
    local host=$1
    sudo -u $SFTP_USERNAME ssh-keyscan -H $host >> /home/$SFTP_USERNAME/.ssh/known_hosts
    sshpass -p "$SFTP_PASSWORD" ssh-copy-id -o StrictHostKeyChecking=no -i /home/$SFTP_USERNAME/.ssh/id_rsa.pub $SFTP_USERNAME@$host
}

# Ensure sshpass is installed
sudo apt-get update
sudo apt-get install -y sshpass

for vm in "${vms[@]}"; do
    if [[ $vm != $(hostname -I | awk '{print $2}') ]]; then
        echo "Copying SSH key to $vm"
        copy_ssh_key $vm
    fi
done

echo "SSH key exchange complete."