#!/bin/bash

# Array of all VM IPs
vms=("192.168.33.11" "192.168.33.12" "192.168.33.13")

copy_ssh_key() {
    local host=$1
    ssh-keyscan -H $host >> ~/.ssh/known_hosts
    sshpass -p "vagrant" ssh-copy-id -o StrictHostKeyChecking=no -i ~/.ssh/id_rsa.pub vagrant@$host
    #ssh-copy-id -i ~/.ssh/id_rsa.pub vagrant@$host
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

sudo sed -i 's/^PasswordAuthentication yes/PasswordAuthentication no/' /etc/ssh/sshd_config
sudo systemctl restart sshd

echo "Password authentication disabled. SSH configuration updated."