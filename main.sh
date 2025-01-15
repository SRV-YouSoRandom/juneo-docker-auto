#!/bin/bash

# Styled header
clear
echo -e "\033[1;34m*******************************************\033[0m"
echo -e "\033[1;34m*                                         *\033[0m"
echo -e "\033[1;34m*               By SRV                   *\033[0m"
echo -e "\033[1;34m*      JuneoGo Docker Auto Setup         *\033[0m"
echo -e "\033[1;34m*                                         *\033[0m"
echo -e "\033[1;34m*******************************************\033[0m"

# Update and install prerequisites
echo -e "\033[1;32m[INFO] Updating package list and installing prerequisites...\033[0m"
sudo apt-get update
sudo apt-get install -y ca-certificates curl git

# Add Docker's GPG key
echo -e "\033[1;32m[INFO] Adding Docker's official GPG key...\033[0m"
sudo install -m 0755 -d /etc/apt/keyrings
sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
sudo chmod a+r /etc/apt/keyrings/docker.asc

# Add Docker's repository
echo -e "\033[1;32m[INFO] Adding Docker's repository...\033[0m"
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu \
  $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | \
  sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
sudo apt-get update

# Install Docker
echo -e "\033[1;32m[INFO] Installing Docker...\033[0m"
sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

# Verify Docker installation
echo -e "\033[1;32m[INFO] Verifying Docker installation...\033[0m"
sudo docker run hello-world

# Clone the repository
echo -e "\033[1;32m[INFO] Cloning the JuneoGo Docker repository...\033[0m"
git clone https://github.com/Juneo-io/juneogo-docker
cd juneogo-docker

# Edit docker-compose.yml
echo -e "\033[1;32m[INFO] Editing docker-compose.yml...\033[0m"
sed -i 's/# - 9650:9650.*/- 9650:9650 # port for API calls - will enable remote RPC calls to your node (mandatory for Supernet\/ Blockchain deployers)/' docker-compose.yml

# Create .env file
echo -e "\033[1;32m[INFO] Creating .env file...\033[0m"
cat <<EOL > .env
CADDY_EMAIL=your-email@example.com
CADDY_DOMAIN=your-domain.com
CADDY_USER=your-username
CADDY_PASSWORD=your-password
EOL

# Build and run the Docker containers
echo -e "\033[1;32m[INFO] Building and starting Docker containers...\033[0m"
docker compose build
docker compose up -d juneogo

# Ask the user if they want to create a backup
read -p "Do you want to create a backup of staking files? (y/n): " backup_choice
if [[ "$backup_choice" == "y" || "$backup_choice" == "yes" ]]; then
    echo -e "\033[1;32m[INFO] Creating backup of staking files...\033[0m"
    mkdir -p ~/juneo-staking-backup
    cp juneogo/.juneogo/staking/* ~/juneo-staking-backup/
    echo -e "\033[1;32m[INFO] Backup created in ~/juneo-staking-backup.\033[0m"
else
    echo -e "\033[1;33m[INFO] Skipping backup creation.\033[0m"
fi

# Completion message
echo -e "\033[1;34m*******************************************\033[0m"
echo -e "\033[1;34m* Installation Complete - By SRV         *\033[0m"
echo -e "\033[1;34m*******************************************\033[0m"
