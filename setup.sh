#!/bin/bash

set -e  # Exit immediately on error

# Check for sudo
if [ "$(id -u)" -ne 0 ]; then
    echo "❌ Please run this script as root or with sudo privileges."
    exit 1
fi

# Check if python3.10 is already installed and working
if command -v python3.10 >/dev/null 2>&1; then
    echo "✅ Python 3.10 is already installed at $(command -v python3.10)"
    PYTHON_BIN=$(command -v python3.10)
else
    echo "🔍 Python 3.10 not found. Proceeding with source installation..."

    echo "🔧 Installing build dependencies..."
    sudo apt update
    sudo apt install -y build-essential libssl-dev zlib1g-dev libbz2-dev \
    libreadline-dev libsqlite3-dev wget curl llvm libncursesw5-dev xz-utils \
    tk-dev libxml2-dev libxmlsec1-dev libffi-dev liblzma-dev

    cd ~
    if [ ! -f Python-3.10.13.tgz ]; then
        echo "📥 Downloading Python 3.10.13 source..."
        wget https://www.python.org/ftp/python/3.10.13/Python-3.10.13.tgz
    fi
    tar -xf Python-3.10.13.tgz
    cd Python-3.10.13

    echo "⚙️ Building and installing Python 3.10.13..."
    ./configure --enable-optimizations
    make -j$(nproc)
    sudo make altinstall

    PYTHON_BIN="/usr/local/bin/python3.10"

    if ! [ -x "$PYTHON_BIN" ]; then
        echo "❌ Python 3.10 installation failed. Check the output above for errors."
        exit 1
    fi
fi

# Ensure pip is available for Python 3.10
$PYTHON_BIN -m ensurepip --upgrade || {
    echo "❌ Failed to install pip for Python 3.10."
    exit 1
}
$PYTHON_BIN -m pip install --upgrade pip

# Setup project directory in user's home
PROJECT_DIR="$(eval echo ~$SUDO_USER)/Bible"
mkdir -p "$PROJECT_DIR"
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
    echo "📦 Installing packages from requirements.txt..."
    if ! pip install -r requirements.txt; then
        echo "❌ Failed to install packages from requirements.txt."
        deactivate
        exit 1
    fi

    if ! pip install -e .; then
        echo "❌ Failed to install the local package with pip install -e ."
        deactivate
        exit 1
    fi
else
    echo "❌ requirements.txt not found in the project directory."
    deactivate
    exit 1
fi

deactivate
echo "✅ Setup complete. Environment ready and dependencies installed."

# Create helper script to run the Bible app
cat << 'EOF' > "$HOME/Bible/run_bible.sh"
#!/bin/bash
source "$HOME/Bible/venv/bin/activate"
python -m bible.main
EOF


# Ensure run_bible.sh is executable
chmod +x "$HOME/Bible/run_bible.sh"

# Create ~/.local/bin if it doesn't exist
mkdir -p "$HOME/.local/bin"

# Symlink Bible launcher
ln -sf "$HOME/Bible/run_bible.sh" "$HOME/.local/bin/bible"
echo "🔗 Symlink created: run the app with 'bible' (make sure ~/.local/bin is in your PATH)"

# Try /usr/local/bin if writeable
if [ -w /usr/local/bin ]; then
    sudo ln -sf "$HOME/Bible/run_bible.sh" /usr/local/bin/bible
    echo "🔗 Also linked to /usr/local/bin/bible"
else
    echo "⚠️  Cannot write to /usr/local/bin. Run manually if needed:"
    echo "    sudo ln -sf \"$HOME/Bible/run_bible.sh\" /usr/local/bin/bible"
fi

