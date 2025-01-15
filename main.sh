#!/bin/bash

# Styled header that stays fixed at the top
clear
echo -e "\033[1;34m*******************************************\033[0m"
echo -e "\033[1;34m*                                         *\033[0m"
echo -e "\033[1;34m*               By SRV                   *\033[0m"
echo -e "\033[1;34m*      JuneoGo Docker Auto Setup         *\033[0m"
echo -e "\033[1;34m*                                         *\033[0m"
echo -e "\033[1;34m*******************************************\033[0m"
echo ""

# Function to print status messages (appears after the header)
print_status() {
    echo -e "\033[1;32m[INFO] $1\033[0m"
}

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
print_status "Updating package list and installing prerequisites..."
sudo apt-get update
sudo apt-get install -y ca-certificates curl git

# Add Docker's GPG key
print_status "Adding Docker's official GPG key..."
sudo install -m 0755 -d /etc/apt/keyrings
sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
sudo chmod a+r /etc/apt/keyrings/docker.asc

# Add Docker's repository
print_status "Adding Docker's repository..."
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu \
  $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | \
  sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
sudo apt-get update

# Install Docker
print_status "Installing Docker..."
sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

# Verify Docker installation
print_status "Verifying Docker installation..."
sudo docker run hello-world

# Clone the repository
print_status "Cloning the JuneoGo Docker repository..."
git clone https://github.com/Juneo-io/juneogo-docker
cd juneogo-docker

# Edit docker-compose.yml
print_status "Editing docker-compose.yml..."
sed -i 's/# - 9650:9650.*/- 9650:9650 # port for API calls - will enable remote RPC calls to your node (mandatory for Supernet\/ Blockchain deployers)/' docker-compose.yml

# Create .env file
print_status "Creating .env file..."
cat <<EOL > .env
CADDY_EMAIL=your-email@example.com
CADDY_DOMAIN=your-domain.com
CADDY_USER=your-username
CADDY_PASSWORD=your-password
EOL

# Build and run the Docker containers
print_status "Building and starting Docker containers..."
docker compose build
docker compose up -d juneogo

# Completion message
echo -e "\033[1;34m*******************************************\033[0m"
echo -e "\033[1;34m* Installation Complete - By SRV         *\033[0m"
echo -e "\033[1;34m*******************************************\033[0m"
