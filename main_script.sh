#!/bin/bash

# Directories and file paths
TERRAFORM_DIR="/home/ubuntu/bash-practise/megalapot/terraform_files"
ANSIBLE_DIR="/home/ubuntu/bash-practise/megalapot/ansible_files"
INVENTORY_FILE="$ANSIBLE_DIR/inventory.yml"

# Exit on any error
set -e

# Check for required tools
echo "Checking for required tools..."
for cmd in terraform ansible; do
  if ! command -v $cmd &> /dev/null; then
    echo "Error: $cmd is not installed. Please install it and try again."
    exit 1
  fi
done

# Terraform deployment
echo "-----------------------------------------------------"
echo "Starting Infrastructure Deployment with Terraform..."
echo "-----------------------------------------------------"

cd "$TERRAFORM_DIR"

if [[ -z "$AWS_SECRET_ACCESS_KEY" || -z "$AWS_ACCESS_KEY_ID" ]]; then
  export AWS_SECRET_ACCESS_KEY="<your aws secret key>"
  export AWS_ACCESS_KEY_ID="<your aws access key>"
  echo "AWS environment variables set."
fi

echo "Initializing Terraform..."
terraform init -input=false

echo "Applying Terraform configuration..."
terraform apply -auto-approve

# Retrieve outputs from Terraform
PUBLIC_DNS=$(terraform output -raw public_dns)
PUBLIC_IP=$(terraform output -raw public_ip)

if [ -z "$PUBLIC_DNS" ]; then
  echo "Error: Could not retrieve public DNS from Terraform output."
  exit 1
else
  echo "Public DNS retrieved: $PUBLIC_DNS"
fi

# Update Ansible inventory
cd "$ANSIBLE_DIR"
sed -i "s/^ *ansible_host: .*/      ansible_host: $PUBLIC_DNS/" "inventory.yml"

# Ansible configuration
echo "-----------------------------------------------------"
echo "Running Ansible playbook..."
echo "-----------------------------------------------------"
ansible-playbook -i inventory.yml playbook.yml

# Display site information
echo "-----------------------------------------------------"
echo "Your site is available at: http://$PUBLIC_IP"
echo "-----------------------------------------------------"
