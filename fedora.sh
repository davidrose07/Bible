#!/bin/bash

set -e  # Exit on error

# Check for sudo
if [ "$(id -u)" -ne 0 ]; then
    echo "❌ Please run this script as root or with sudo privileges."
    exit 1
fi

# Check if python3.10 is already installed
if command -v python3.10 >/dev/null 2>&1; then
    echo "✅ Python 3.10 already installed at $(command -v python3.10)"
    PYTHON_BIN=$(command -v python3.10)
else
    echo "🔍 Python 3.10 not found. Proceeding with source installation..."

    echo "🔧 Installing build dependencies..."
    dnf install -y @development-tools
    dnf install -y gcc openssl-devel bzip2-devel libffi-devel zlib-devel \
        readline-devel sqlite-devel wget xz-devel tk-devel ncurses-devel \
        libuuid-devel libxml2-devel libxmlsec1-devel

    cd ~
    if [ ! -f Python-3.10.12.tgz ]; then
        echo "📥 Downloading Python 3.10.12..."
        wget https://www.python.org/ftp/python/3.10.12/Python-3.10.12.tgz
    fi
    tar -xf Python-3.10.12.tgz
    cd Python-3.10.12

    echo "⚙️ Building Python 3.10.12..."
    ./configure --enable-optimizations
    make -j$(nproc)
    make altinstall

    PYTHON_BIN="/usr/local/bin/python3.10"

    if ! [ -x "$PYTHON_BIN" ]; then
        echo "❌ Python 3.10 installation failed."
        exit 1
    fi
fi

# Ensure pip
$PYTHON_BIN -m ensurepip --upgrade || {
    echo "❌ Failed to install pip for Python 3.10."
    exit 1
}
$PYTHON_BIN -m pip install --upgrade pip

# Set up project directory
PROJECT_DIR="$(eval echo ~$SUDO_USER)/Bible"
mkdir -p "$PROJECT_DIR"
cd "$PROJECT_DIR"

# Create and activate virtual env
echo "🐍 Creating venv in $PROJECT_DIR/venv"
$PYTHON_BIN -m venv venv

if [ ! -f venv/bin/activate ]; then
    echo "❌ Virtual environment was not created successfully."
    exit 1
fi

source venv/bin/activate

if [ -f "requirements.txt" ]; then
    echo "📦 Installing dependencies..."
    if ! pip install -r requirements.txt; then
        echo "❌ Failed to install from requirements.txt."
        deactivate
        exit 1
    fi
    if ! pip install -e .; then
        echo "❌ Failed to install the local package."
        deactivate
        exit 1
    fi
else
    echo "❌ requirements.txt not found."
    deactivate
    exit 1
fi

deactivate

cat << EOF > "$PROJECT_DIR/run_bible.sh"
#!/bin/bash
source "$PROJECT_DIR/venv/bin/activate"
python -m bible.main
EOF



chmod +x "$PROJECT_DIR/run_bible.sh"

REAL_HOME="$(getent passwd "$SUDO_USER" | cut -d: -f6)"
mkdir -p "$REAL_HOME/.local/bin"
ln -sf "$PROJECT_DIR/run_bible.sh" "$REAL_HOME/.local/bin/bible"
echo "🔗 Symlink created in $REAL_HOME/.local/bin/bible"

if [ -w /usr/local/bin ]; then
    ln -sf "$PROJECT_DIR/run_bible.sh" /usr/local/bin/bible
    echo "🔗 Also symlinked globally: /usr/local/bin/bible"
else
    echo "⚠️ Cannot write to /usr/local/bin. Run manually if needed:"
    echo "    sudo ln -sf \"$PROJECT_DIR/run_bible.sh\" /usr/local/bin/bible"
fi

echo "✅ Fedora setup complete. Run 'bible' to start the application."
