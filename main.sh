#!/bin/bash

# Styled header
clear
echo -e "\033[1;34m*******************************************\033[0m"
echo -e "\033[1;34m*                                         *\033[0m"
echo -e "\033[1;34m*               By SRV                   *\033[0m"
echo -e "\033[1;34m*      JuneoGo Docker Auto Setup         *\033[0m"
echo -e "\033[1;34m*                                         *\033[0m"
echo -e "\033[1;34m*******************************************\033[0m"

# Check if port 9650 is in use
check_port_9650() {
    if ss -tuln | grep -q ":9650"; then
        echo -e "\033[1;31m[ERROR] Port 9650 is already in use. Please free it before proceeding.\033[0m"
        exit 1
    fi
}

# Check if Docker is installed
check_docker_installed() {
    if ! command -v docker &> /dev/null; then
        echo -e "\033[1;33m[WARNING] Docker is not installed. Proceeding with installation...\033[0m"
        return 1
    fi
    return 0
}

# Check for running JuneoGo container
check_juneogo_container() {
    if check_docker_installed; then
        if docker ps --filter "name=juneogo" --format '{{.Names}}' | grep -q "juneogo"; then
            echo -e "\033[1;31m[ERROR] A container named 'juneogo' is already running. Please stop it before proceeding.\033[0m"
            exit 1
        fi
    fi
}

# Perform pre-checks
check_port_9650
check_juneogo_container

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
    cp -r juneogo/.juneogo/staking/ ~/juneo-staking-backup
    if [[ $? -eq 0 ]]; then
        echo -e "\033[1;32m[INFO] Backup successfully created in $BACKUP_DIR.\033[0m"
    else
        echo -e "\033[1;31m[ERROR] Failed to create backup. Please check the directory path.\033[0m"
    fi
else
    echo -e "\033[1;33m[INFO] Skipping backup creation.\033[0m"
fi

# Completion message
echo -e "\033[1;34m*******************************************\033[0m"
echo -e "\033[1;34m* Installation Complete - By SRV         *\033[0m"
echo -e "\033[1;34m*******************************************\033[0m"
