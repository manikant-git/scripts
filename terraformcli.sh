#!/bin/bash
set -e

missing_deps=()

# Check dependency presence
for dep in unzip curl wget gpg zip; do
  if ! command -v "$dep" >/dev/null 2>&1; then
    missing_deps+=("$dep")
  fi
done

# Install missing dependencies in one command
if [ ${#missing_deps[@]} -gt 0 ]; then
  echo "Installing dependencies: ${missing_deps[*]}"
  sudo apt-get update
  sudo apt-get install -y "${missing_deps[@]}"
fi

# Install Terraform if not present
if ! command -v terraform >/dev/null 2>&1; then
  echo "Terraform not found. Installing..."
  wget -O- https://apt.releases.hashicorp.com/gpg | \
    sudo gpg --dearmor -o /usr/share/keyrings/hashicorp-archive-keyring.gpg
  echo "deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com $(lsb_release -cs) main" | \
    sudo tee /etc/apt/sources.list.d/hashicorp.list
  sudo apt-get update
  sudo apt-get install -y terraform
else
  echo "Terraform already installed."
fi

terraform --version

# Install AWS CLI v2 if not present
if ! command -v aws >/dev/null 2>&1; then
  echo "AWS CLI not found. Installing..."
  curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
  unzip awscliv2.zip
  sudo ./aws/install
  rm -rf awscliv2.zip aws
else
  echo "AWS CLI already installed."
fi

aws --version
