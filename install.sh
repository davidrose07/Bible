#!/usr/bin/env bash

set -e

APP_NAME="bible"
DOCKERFILE_DIR="$(dirname "$0")"

# Detect OS and distro
OS="$(uname -s)"
DISTRO=""

get_distro() {
    if [ -f /etc/os-release ]; then
        . /etc/os-release
        DISTRO=$ID
    fi
}

# Docker installer for Debian/Ubuntu
install_docker_debian() {
    echo "Installing Docker on Debian/Ubuntu..."

    sudo apt-get update
    sudo apt-get install -y \
        ca-certificates curl gnupg lsb-release apt-transport-https

    sudo install -m 0755 -d /etc/apt/keyrings
    curl -fsSL https://download.docker.com/linux/$DISTRO/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg

    echo \
      "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] \
      https://download.docker.com/linux/$DISTRO $(lsb_release -cs) stable" | \
      sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

    sudo apt-get update
    sudo apt-get install -y docker-ce docker-ce-cli containerd.io

    echo "Docker installed."
}

# Docker installer for Arch Linux
install_docker_arch() {
    echo "Installing Docker on Arch Linux..."
    sudo pacman -Sy --noconfirm docker
    echo "Docker installed."
}

# Docker installer for Fedora/RHEL
install_docker_fedora() {
    echo "Installing Docker on Fedora/RHEL..."
    sudo dnf -y install dnf-plugins-core
    sudo dnf config-manager \
        --add-repo https://download.docker.com/linux/fedora/docker-ce.repo
    sudo dnf install -y docker-ce docker-ce-cli containerd.io
    echo "Docker installed."
}

# Docker installer for Alpine
install_docker_alpine() {
    echo "Installing Docker on Alpine Linux..."
    sudo apk add docker
    echo "Docker installed."
}

# macOS / Windows placeholders
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
        get_distro
        echo "Detected Linux distro: $DISTRO"

        case "$DISTRO" in
            ubuntu|debian) install_docker_debian ;;
            arch)          install_docker_arch ;;
            fedora|rhel)   install_docker_fedora ;;
            alpine)        install_docker_alpine ;;
            *)             echo "Unsupported Linux distro: $DISTRO" && exit 1 ;;
        esac

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
docker build -t "$APP_NAME" "$DOCKERFILE_DIR"

echo "Running Docker container..."
docker run -it "$APP_NAME"
