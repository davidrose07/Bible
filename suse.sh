#!/bin/bash

set -e  # Exit on any error

# Check for sudo
if [ "$(id -u)" -ne 0 ]; then
    echo "❌ Please run this script as root or with sudo privileges."
    exit 1
fi

# Check for Python 3.10
if command -v python3.10 >/dev/null 2>&1; then
    echo "✅ Python 3.10 already installed at $(command -v python3.10)"
    PYTHON_BIN=$(command -v python3.10)
else
    echo "🔍 Python 3.10 not found. Installing from source..."

    echo "🔧 Installing build dependencies..."
    zypper refresh
    zypper install -y gcc make zlib-devel libffi-devel xz libopenssl-devel \
        bzip2-devel readline-devel sqlite3-devel ncurses-devel tk-devel \
        libxml2-devel libxmlsec1-devel lzma-devel wget tar

    cd /usr/src
    if [ ! -f Python-3.10.12.tgz ]; then
        wget https://www.python.org/ftp/python/3.10.12/Python-3.10.12.tgz
    fi

    tar -xf Python-3.10.12.tgz
    cd Python-3.10.12

    ./configure --enable-optimizations
    make -j$(nproc)
    make altinstall

    PYTHON_BIN="/usr/local/bin/python3.10"

    if ! [ -x "$PYTHON_BIN" ]; then
        echo "❌ Python 3.10 installation failed."
        exit 1
    fi
fi

# Ensure pip is available
$PYTHON_BIN -m ensurepip --upgrade || {
    echo "❌ Failed to install pip for Python 3.10."
    exit 1
}
$PYTHON_BIN -m pip install --upgrade pip

# Set up project directory
REAL_HOME="$(getent passwd $SUDO_USER | cut -d: -f6)"
PROJECT_DIR="$REAL_HOME/Bible"
mkdir -p "$PROJECT_DIR"
cd "$PROJECT_DIR"

# Create virtual environment
$PYTHON_BIN -m venv venv
if [ ! -f venv/bin/activate ]; then
    echo "❌ Virtual environment creation failed."
    exit 1
fi

source venv/bin/activate

# Install Python packages
if [ -f "requirements.txt" ]; then
    pip install -r requirements.txt || {
        echo "❌ Failed to install packages from requirements.txt."
        deactivate
        exit 1
    }
    pip install -e . || {
        echo "❌ Failed to install local package."
        deactivate
        exit 1
    }
else
    echo "❌ requirements.txt not found."
    deactivate
    exit 1
fi

deactivate

# Create launcher script
cat << 'EOF' > "$REAL_HOME/Bible/run_bible.sh"
#!/bin/bash
source "$HOME/Bible/venv/bin/activate"
python -m bible.main
EOF
chmod +x "$REAL_HOME/Bible/run_bible.sh"

# Create symlink
mkdir -p "$REAL_HOME/.local/bin"
ln -sf "$REAL_HOME/Bible/run_bible.sh" "$REAL_HOME/.local/bin/bible"
echo "🔗 Symlink created in $REAL_HOME/.local/bin/bible"

# Optionally symlink to /usr/local/bin
if [ -w /usr/local/bin ]; then
    ln -sf "$REAL_HOME/Bible/run_bible.sh" /usr/local/bin/bible
    echo "🔗 Global symlink created at /usr/local/bin/bible"
else
    echo "⚠️  Cannot write to /usr/local/bin. Run manually if needed:"
    echo "    sudo ln -sf \"$REAL_HOME/Bible/run_bible.sh\" /usr/local/bin/bible"
fi

echo "✅ Setup complete. You can now run the Bible app with: bible"
