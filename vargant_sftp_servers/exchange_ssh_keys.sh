#!/bin/bash

# Array of all VM IPs
vms=("192.168.33.11" "192.168.33.12" "192.168.33.13")

copy_ssh_key() {
    local host=$1
    ssh-keyscan -H $host >> ~/.ssh/known_hosts
    #TODO sshpass -f password.txt ssh-copy-id user@yourserver
    ssh-copy-id -i ~/.ssh/id_rsa.pub vagrant@$host
}

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