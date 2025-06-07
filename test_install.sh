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
    echo "Installing Docker using dnf..."
    sudo dnf -y install dnf-plugins-core
    sudo dnf config-manager \
        --add-repo https://download.docker.com/linux/fedora/docker-ce.repo
    sudo dnf install -y docker-ce docker-ce-cli containerd.io
}

install_docker_apk() {
    echo "Installing Docker using apk..."
    sudo apk add docker
}

install_docker_mac() {
    echo "Please install Docker Desktop manually from https://www.docker.com/products/docker-desktop"
    exit 1
}

install_docker_windows() {
    echo "Please install Docker Desktop manually from https://www.docker.com/products/docker-desktop"
    exit 1
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

# Build and run
echo "Building Docker image..."
sudo docker build -t "$APP_NAME" "$DOCKERFILE_DIR"

echo "Running Docker container..."
sudo docker run -it "$APP_NAME"
