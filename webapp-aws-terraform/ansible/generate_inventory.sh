#!/bin/bash

# Usage: ./generate_inventory.sh [path_to_terraform_outputs.json]

# Set default path if not provided
TERRAFORM_OUTPUTS_JSON=${1:-terraform_outputs.json}

# Read instance IDs and private IPs from Terraform outputs
jq -r '.instance_ids_map.value | to_entries[] | "\(.key) \(.value)"' "$TERRAFORM_OUTPUTS_JSON" > instance_ids.txt
jq -r '.private_ips_map.value | to_entries[] | "\(.key) \(.value)"' "$TERRAFORM_OUTPUTS_JSON" > private_ips.txt

echo "[all]" > hosts
while read line; do
  name=$(echo $line | cut -d' ' -f1)
  id=$(echo $line | cut -d' ' -f2)
  private_ip=$(grep "^$name " private_ips.txt | cut -d' ' -f2)
  echo "$id ansible_host=$id ansible_connection=aws_ssm ansible_user=ssm-user private_ip=$private_ip" >> hosts
done < instance_ids.txt

echo "" >> hosts

for group in frontend backend postgres mongodb redis; do
  echo "[$group]" >> hosts
  grep "^$group " instance_ids.txt | awk '{print $2}' >> hosts
  echo "" >> hosts
done
