#!/bin/bash

set -e  # Exit on error

# Make sure we're running with root privileges
if [ "$(id -u)" -ne 0 ]; then
    echo "❌ Please run this script with sudo or as root."
    exit 1
fi

echo "📦 Updating repositories..."
zypper refresh

echo "📥 Installing build dependencies..."
zypper install -y gcc make wget curl \
    libopenssl-devel libffi-devel libbz2-devel \
    zlib-devel readline-devel sqlite3-devel \
    ncurses-devel tk-devel xz-devel \
    libxml2-devel libxmlsec1-devel lzma-devel

# Check for Python 3.10
if command -v python3.10 >/dev/null 2>&1; then
    echo "✅ Python 3.10 is already installed at $(command -v python3.10)"
    PYTHON_BIN=$(command -v python3.10)
else
    echo "🐍 Python 3.10 not found. Installing from source..."

    cd ~
    if [ ! -f Python-3.10.12.tgz ]; then
        wget https://www.python.org/ftp/python/3.10.12/Python-3.10.12.tgz
    fi
    tar -xf Python-3.10.12.tgz
    cd Python-3.10.12
    ./configure --enable-optimizations
    make -j$(nproc)
    make altinstall
    PYTHON_BIN="/usr/local/bin/python3.10"
fi

# Ensure pip is available
$PYTHON_BIN -m ensurepip --upgrade || {
    echo "❌ Failed to install pip."
    exit 1
}
$PYTHON_BIN -m pip install --upgrade pip

# Setup project directory
REAL_HOME="$(eval echo ~$SUDO_USER)"
PROJECT_DIR="$REAL_HOME/Bible"
mkdir -p "$PROJECT_DIR"
cd "$PROJECT_DIR"

# Create and activate virtual environment
echo "🐍 Creating virtual environment at $PROJECT_DIR/venv"
$PYTHON_BIN -m venv venv
source venv/bin/activate

# Install dependencies
if [ -f "requirements.txt" ]; then
    echo "📦 Installing Python dependencies..."
    pip install -r requirements.txt
    pip install -e .
else
    echo "❌ requirements.txt not found!"
    deactivate
    exit 1
fi

deactivate
echo "✅ Setup complete."

# Create launcher script
cat << 'EOF' > "$REAL_HOME/Bible/run_bible.sh"
#!/bin/bash
source "$HOME/Bible/venv/bin/activate"
python -m bible.main
EOF

chmod +x "$REAL_HOME/Bible/run_bible.sh"
mkdir -p "$REAL_HOME/.local/bin"
ln -sf "$REAL_HOME/Bible/run_bible.sh" "$REAL_HOME/.local/bin/bible"
echo "🔗 Symlink created: run the app with 'bible'"
