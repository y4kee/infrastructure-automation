#!/bin/bash

terraform_directory="/home/ubuntu/bash-practise/megalapot/terraform_files"
ansible_directory="/home/ubuntu/bash-practise/megalapot/ansible_files"
inventory_file="$ansible_directory/inventory.yml"

set -e #Stop if something went wrong

# Is all necessary packages exists
command -v terraform > /dev/null 2>&1 || { echo "Terraform doesn\`t find. Install terraform and try again"; exit 1; }
command -v ansible > /dev/null 2>&1 || { echo "Ansible doesn\`t find. Install terraform and try again"; exit 1; }

# Infrastructure Deployment
echo "-----------------------------------------------------"
echo "Starting Infrastructure Deployment with Terraform..."
echo "-----------------------------------------------------"

cd $terraform_directory

if [[ -z "$AWS_SECRET_ACCESS_KEY"  &&  -z "$AWS_ACCESS_KEY_ID" ]]; then
  export AWS_SECRET_ACCESS_KEY=<"your aws secret key">
  export AWS_ACCESS_KEY_ID=<"your aws access key">
  
  echo "-----------------------------------------------------"
  printf "Enviroment variables was successfully seted!\nTerrafrom initialization...\n"
  echo "-----------------------------------------------------"
  
  terraform init -input=false
  echo "-----------------------------------------------------"
  printf "Terrafrom applying...\n"
  echo "-----------------------------------------------------"
  terraform apply -auto-approve
else
  printf "Terrafrom initialization..."
  terraform init -input=false
  terraform apply -auto-approve
fi

PUBLIC_DNS=$(terraform output -raw public_dns)
PUBLIC_IP=$(terraform output -raw public_ip)

# Check if the PUBLIC_DNS variable is populated
if [ -z "$PUBLIC_DNS" ]; then
  echo "Error: Could not retrieve public DNS from Terraform output."
  exit 1
else
  echo "Public DNS retrieved: $PUBLIC_DNS"
fi

cd $ansible_directory
sed -i "s/^ *ansible_host: .*/      ansible_host: $PUBLIC_DNS/" "$inventory_file"




# Ansible configuration
echo "Asnsible..."
ansible-playbook -i inventory.yml playbook.yml

echo "Your site is avaliable on this IP: $PUBLIC_IP"