#!/bin/bash

sudo sed -i 's/^PasswordAuthentication yes/PasswordAuthentication no/' /etc/ssh/sshd_config
sudo systemctl restart sshd

echo "Password authentication disabled. SSH configuration updated."