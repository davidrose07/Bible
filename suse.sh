#!/bin/bash

set -e  # Exit on error



# Save real user's home (important when using sudo)
REAL_USER=${SUDO_USER:-$USER}
REAL_HOME=$(eval echo "~$REAL_USER")
PROJECT_DIR="$REAL_HOME/Bible"

echo "📦 Refreshing package list..."
zypper refresh

echo "📥 Installing development dependencies..."
zypper install -y gcc make wget curl \
    libopenssl-devel libffi-devel libbz2-devel \
    zlib-devel readline-devel sqlite3-devel \
    ncurses-devel tk-devel xz-devel \
    libxml2-devel lzma-devel

# Check if Python 3.10 is already available
if command -v python3.10 >/dev/null 2>&1; then
    echo "✅ Found Python 3.10 at: $(command -v python3.10)"
    PYTHON_BIN=$(command -v python3.10)
else
    echo "🐍 Python 3.10 not found. Installing from source..."

    cd "$REAL_HOME"
    if [ ! -f Python-3.10.12.tgz ]; then
        wget https://www.python.org/ftp/python/3.10.12/Python-3.10.12.tgz
    fi
    tar -xf Python-3.10.12.tgz
    cd $REAL_HOME/Python-3.10.12
    ./configure --enable-optimizations
    make -j$(nproc)
    make altinstall
    PYTHON_BIN="/usr/local/bin/python3.10"
fi

# Install pip for Python 3.10
$PYTHON_BIN -m ensurepip --upgrade || {
    echo "❌ Failed to install pip."
    exit 1
}
$PYTHON_BIN -m pip install --upgrade pip

# Setup project
mkdir -p "$PROJECT_DIR"
cd "$PROJECT_DIR"

echo "🐍 Creating virtual environment in $PROJECT_DIR/venv"
$PYTHON_BIN -m venv venv

if [ ! -f venv/bin/activate ]; then
    echo "❌ Failed to create virtual environment."
    exit 1
fi

source venv/bin/activate

if [ -f "requirements.txt" ]; then
    echo "📦 Installing Python packages..."
    pip install -r requirements.txt || {
        echo "❌ Failed to install from requirements.txt"
        deactivate
        exit 1
    }

    pip install -e . || {
        echo "❌ Failed to install local package"
        deactivate
        exit 1
    }
else
    echo "❌ requirements.txt not found!"
    deactivate
    exit 1
fi

deactivate
echo "✅ Setup complete."

# Create a launcher script
LAUNCH_SCRIPT="$REAL_HOME/Bible/run_bible.sh"
cat << 'EOF' > "$LAUNCH_SCRIPT"
#!/bin/bash
source "$HOME/Bible/venv/bin/activate"
python -m bible.main
EOF

chmod +x "$LAUNCH_SCRIPT"

# Link to ~/.local/bin
mkdir -p "$REAL_HOME/.local/bin"
ln -sf "$LAUNCH_SCRIPT" "$REAL_HOME/.local/bin/bible"
echo "🔗 You can now run the Bible app by typing: bible"
