#!/bin/bash

# Check for sudo access
if [ "$(id -u)" -ne 0 ]; then
    echo "Please run as root or with sudo privileges."
    exit 1
fi

# Update package list and install build dependencies
sudo apt update -y
sudo apt install -y wget build-essential libssl-dev zlib1g-dev \
    libncurses5-dev libncursesw5-dev libreadline-dev libsqlite3-dev \
    libgdbm-dev libdb5.3-dev libbz2-dev libexpat1-dev liblzma-dev tk-dev

# Set path to your custom Python install
PY310=/usr/local/bin/python3.10

# Check if Python 3.10 exists
if [ ! -x "$PY310" ]; then
    echo "Python 3.10 not found at $PY310. Make sure it's installed."
    exit 1
fi

# Create project directory and move into it
PROJECT_DIR=~/Bible
mkdir -p "$PROJECT_DIR"
cd "$PROJECT_DIR" || exit 1

# Create and activate virtual environment
$PY310 -m venv venv
source venv/bin/activate

# Install requirements
if [ -f "requirements.txt" ]; then
    pip install -r requirements.txt
    pip install -e .
else
    echo "requirements.txt not found in the current directory."
fi

deactivate
echo "Setup complete. Virtual environment created using Python 3.10."
