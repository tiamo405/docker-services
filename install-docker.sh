#!/bin/bash

# Docker and Docker Compose Installation Script for Ubuntu
# This script installs Docker, Docker Compose and adds current user to docker group

set -e  # Exit on any error

echo "=== Docker and Docker Compose Installation Script ==="
echo "Starting installation process..."

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Function to print colored output
print_status() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Check if running as root
if [ "$EUID" -eq 0 ]; then
    print_error "Please do not run this script as root. Run as regular user with sudo privileges."
    exit 1
fi

# Update package list
print_status "Updating package list..."
sudo apt update

# Install prerequisites
print_status "Installing prerequisites..."
sudo apt install -y \
    apt-transport-https \
    ca-certificates \
    curl \
    gnupg \
    lsb-release \
    software-properties-common

# Remove old Docker versions if they exist
print_status "Removing old Docker versions..."
sudo apt remove -y docker docker-engine docker.io containerd runc 2>/dev/null || true

# Add Docker's official GPG key
print_status "Adding Docker's GPG key..."
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg

# Add Docker repository
print_status "Adding Docker repository..."
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu \
  $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

# Update package list again
print_status "Updating package list with Docker repository..."
sudo apt update

# Install Docker Engine
print_status "Installing Docker Engine..."
sudo apt install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin

# Start and enable Docker service
print_status "Starting and enabling Docker service..."
sudo systemctl start docker
sudo systemctl enable docker

# Add current user to docker group
print_status "Adding user '$USER' to docker group..."
sudo usermod -aG docker $USER

# Get latest Docker Compose version
print_status "Getting latest Docker Compose version..."
COMPOSE_VERSION=$(curl -s https://api.github.com/repos/docker/compose/releases/latest | grep -Po '"tag_name": "\K.*?(?=")')

# Install Docker Compose
print_status "Installing Docker Compose version $COMPOSE_VERSION..."
sudo curl -L "https://github.com/docker/compose/releases/download/$COMPOSE_VERSION/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose

# Make Docker Compose executable
sudo chmod +x /usr/local/bin/docker-compose

# Create symbolic link for easier access
sudo ln -sf /usr/local/bin/docker-compose /usr/bin/docker-compose

# Install bash completion for Docker Compose
print_status "Installing bash completion for Docker Compose..."
sudo curl -L "https://raw.githubusercontent.com/docker/compose/$COMPOSE_VERSION/contrib/completion/bash/docker-compose" -o /etc/bash_completion.d/docker-compose

# Test Docker installation
print_status "Testing Docker installation..."
if sudo docker run hello-world > /dev/null 2>&1; then
    print_status "Docker installation successful!"
else
    print_error "Docker installation failed!"
    exit 1
fi

# Display versions
echo ""
echo "=== Installation Complete ==="
print_status "Docker version:"
docker --version

print_status "Docker Compose version:"
docker-compose --version

echo ""
print_warning "IMPORTANT: You need to log out and log back in (or restart your system)"
print_warning "for the group membership changes to take effect."
print_warning "After that, you can run Docker commands without sudo."

echo ""
print_status "To test Docker without sudo after relogin, run:"
echo "  docker run hello-world"

echo ""
print_status "To test Docker Compose, run:"
echo "  docker-compose --version"

echo ""
print_status "Installation completed successfully!"
