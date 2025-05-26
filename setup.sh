#!/bin/bash

# Exit on any command failure
set -e

# Check for sudo
if [ "$(id -u)" -ne 0 ]; then
    echo "❌ Please run this script as root or with sudo privileges."
    exit 1
fi

echo "🔧 Updating packages and installing build dependencies..."
sudo apt update
sudo apt install -y build-essential libssl-dev zlib1g-dev libbz2-dev \
libreadline-dev libsqlite3-dev wget curl llvm libncursesw5-dev xz-utils \
tk-dev libxml2-dev libxmlsec1-dev libffi-dev liblzma-dev

# Download Python source
cd ~
if [ ! -f Python-3.10.12.tgz ]; then
    echo "📥 Downloading Python 3.10.12..."
    wget https://www.python.org/ftp/python/3.10.12/Python-3.10.12.tgz
fi
tar -xf Python-3.10.12.tgz
cd Python-3.10.12

echo "⚙️ Building and installing Python 3.10.12..."
./configure --enable-optimizations
make -j$(nproc)
sudo make altinstall

PYTHON_BIN="/usr/local/bin/python3.10"
if ! [ -x "$PYTHON_BIN" ]; then
    echo "❌ Python 3.10 installation failed. Check for errors above and ensure dependencies are installed."
    echo "Try running: sudo apt install libffi-dev zlib1g-dev libssl-dev build-essential"
    exit 1
fi

# Ensure pip is available and working
$PYTHON_BIN -m ensurepip --upgrade || {
    echo "❌ Failed to install pip for Python 3.10."
    exit 1
}
$PYTHON_BIN -m pip install --upgrade pip

# Project directory setup
PROJECT_DIR=~/Bible
cd "$PROJECT_DIR"

# Create and activate virtual environment
echo "🐍 Creating virtual environment in $PROJECT_DIR/venv"
$PYTHON_BIN -m venv venv

if [ ! -f venv/bin/activate ]; then
    echo "❌ Virtual environment was not created successfully."
    exit 1
fi

source venv/bin/activate

# Install dependencies
if [ -f "requirements.txt" ]; then
    echo "📦 Installing Python dependencies from requirements.txt..."
    if ! pip install -r requirements.txt; then
        echo "❌ Failed to install packages from requirements.txt."
        deactivate
        exit 1
    fi

    if ! pip install -e .; then
        echo "❌ Failed to install the current package with pip install -e ."
        deactivate
        exit 1
    fi
else
    echo "❌ requirements.txt not found in $PROJECT_DIR. Cannot continue."
    deactivate
    exit 1
fi

# Deactivate virtual environment
deactivate

echo "✅ Setup complete. Python 3.10 installed, virtual environment ready, and dependencies installed."
