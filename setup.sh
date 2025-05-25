#!/bin/bash

# Check for sudo access (if needed)
if [ "$(id -u)" -ne 0 ]; then
    echo "Please run as root or with sudo privileges."
    exit 1
fi

# Update package list and install dependencies (for Ubuntu/Debian-based systems)
sudo apt update -y
sudo apt install -y wget software-properties-common

# Add repository for Python 3.10 (if not already available)
sudo add-apt-repository ppa:deadsnakes/ppa -y
sudo apt update -y

# Install Python 3.10
sudo apt install -y python3.10 python3.10-venv python3.10-dev python3-pip


# Ensure pip is available for Python 3.10
python3.10 -m ensurepip --upgrade

# Optional: Install pipx (uncomment if you need it)
# python3.10 -m pip install --user pipx
# python3.10 -m pipx ensurepath

# Check if Python 3.10 is installed correctly
python3.10 --version

# Create a project directory (you can change this to the desired location)
PROJECT_DIR=~/my_project
mkdir -p "$PROJECT_DIR"
cd "$PROJECT_DIR"

# Create a virtual environment with Python 3.10
python3.10 -m venv venv

# Activate the virtual environment
source venv/bin/activate

# Install required Python packages from requirements.txt
if [ -f "requirements.txt" ]; then
    pip install -r requirements.txt
    pip install -e .
else
    echo "requirements.txt not found in the current directory."
fi

# Deactivate the virtual environment
deactivate

echo "Setup complete. Virtual environment created and dependencies installed."
