#!/usr/bin/env bash

set -e

APP_NAME="bible"
DOCKERFILE_DIR="$(dirname "$0")"

# Detect OS
OS="$(uname -s)"

# Docker installer by package manager
install_docker_apt() {
    echo "Installing Docker using apt..."
    sudo apt-get update
    sudo apt-get install -y \
        ca-certificates curl gnupg lsb-release apt-transport-https

    sudo install -m 0755 -d /etc/apt/keyrings
    curl -fsSL https://download.docker.com/linux/$(. /etc/os-release && echo "$ID")/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg

    echo \
      "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] \
      https://download.docker.com/linux/$(lsb_release -is | tr '[:upper:]' '[:lower:]') \
      $(lsb_release -cs) stable" | \
      sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

    sudo apt-get update
    sudo apt-get install -y docker-ce docker-ce-cli containerd.io
}

install_docker_pacman() {
    echo "Installing Docker using pacman..."
    sudo pacman -Sy --noconfirm docker
}

install_docker_dnf() {
    echo "🔧 Installing Docker using dnf..."

    # Step 1: Ensure dnf-plugins-core is installed
    if ! sudo dnf -y install dnf-plugins-core; then
        echo "❌ Failed to install dnf-plugins-core."
        return 1
    fi

    # Step 2: Try to add Docker repo with config-manager
    if ! sudo dnf config-manager --add-repo https://download.docker.com/linux/fedora/docker-ce.repo; then
        echo "⚠️ config-manager failed. Falling back to manual repo setup."
        sudo tee /etc/yum.repos.d/docker-ce.repo > /dev/null <<EOF
[docker-ce-stable]
name=Docker CE Stable - \$basearch
baseurl=https://download.docker.com/linux/fedora/\$releasever/\$basearch/stable
enabled=1
gpgcheck=1
gpgkey=https://download.docker.com/linux/fedora/gpg
EOF
    fi

    # Step 3: Install Docker packages
    if ! sudo dnf install -y docker-ce docker-ce-cli containerd.io; then
        echo "❌ Failed to install Docker packages."
        return 1
    fi

    # Step 4: Enable and start Docker service
    #sudo systemctl enable --now docker
}


install_docker_apk() {
    echo "Installing Docker using apk..."
    sudo apk add docker
}

install_docker_mac() {
    echo "Please install Docker Desktop manually from https://www.docker.com/products/docker-desktop"
    exit 1
}


install_docker_zypper() {
    echo "Installing Docker using zypper..."
    sudo zypper refresh
    sudo zypper install -y docker
    echo "Docker installed."
}


# Determine what to do
if ! command -v docker &> /dev/null; then
    echo "Docker not found. Installing..."

    if [[ "$OS" == "Linux" ]]; then
        if command -v apt-get &> /dev/null; then
            install_docker_apt
        elif command -v pacman &> /dev/null; then
            install_docker_pacman
        elif command -v dnf &> /dev/null; then
            install_docker_dnf
        elif command -v apk &> /dev/null; then
            install_docker_apk
        elif command -v zypper &> /dev/null; then
            install_docker_zypper
        else
            echo "Unsupported or unknown package manager."
            exit 1
        fi

        sudo systemctl enable --now docker
    elif [[ "$OS" == "Darwin" ]]; then
        install_docker_mac
    elif [[ "$OS" =~ MINGW.*|MSYS.*|CYGWIN.* ]]; then
        install_docker_windows
    else
        echo "Unsupported OS: $OS"
        exit 1
    fi
else
    echo "Docker is already installed."
fi

#Make sure docker service is running
check_docker_service() {
    if systemctl is-active --quiet docker && systemctl is-enabled --quiet docker; then
        echo "✅ Docker is running and enabled."
        return 0
    else
        echo "❌ Docker is not running and/or not enabled."
        return 1
    fi
}

if check_docker_service; then
    echo "Proceeding with Docker operations..."
else
    echo "Attempting to start and enable Docker..."
    sudo systemctl start docker
    sudo systemctl enable docker
fi

# Build and run
echo "Building Docker image..."
sudo docker build -t "$APP_NAME" "$DOCKERFILE_DIR"

# Create wrapper script for 'bible' command
echo "Creating system-wide 'bible' command..."

sudo tee /usr/local/bin/bible > /dev/null <<EOF
#!/bin/bash
sudo docker run -it --rm $APP_NAME
EOF

sudo chmod +x /usr/local/bin/bible

echo "✅ You can now run your app with: bible"


