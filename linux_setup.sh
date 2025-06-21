#!/bin/bash

set -e  # Exit immediately on error

# Determine the real user when run with sudo
REAL_USER=${SUDO_USER:-$USER}
REAL_HOME=$(eval echo "~$REAL_USER")
PROJECT_DIR="$REAL_HOME/Bible"

# Ensure script is run as root
if [ "$(id -u)" -ne 0 ]; then
    echo "❌ Please run this script as root or with sudo."
    exit 1
fi

# Detect distro
detect_distro() {
    if [ -f /etc/os-release ]; then
        . /etc/os-release
        echo "$ID"
    else
        echo "unknown"
    fi
}

# Common Python 3.10 install function
install_python_from_source() {
    echo "📅 Downloading and building Python 3.10.12..."
    cd "$REAL_HOME"
    if [ ! -f Python-3.10.12.tgz ]; then
        wget https://www.python.org/ftp/python/3.10.12/Python-3.10.12.tgz
    fi
    tar -xf Python-3.10.12.tgz
    cd Python-3.10.12
    ./configure --enable-optimizations
    make -j$(nproc)
    make altinstall
}

# Install Python based on distro
install_python() {
    case "$(detect_distro)" in
        ubuntu|debian)
            echo "🔧 Installing build dependencies (Debian/Ubuntu)..."
            apt update
            apt install -y build-essential libssl-dev zlib1g-dev libbz2-dev \
            libreadline-dev libsqlite3-dev wget curl llvm libncursesw5-dev \
            xz-utils tk-dev libxml2-dev libxmlsec1-dev libffi-dev liblzma-dev
            install_python_from_source
            ;;
        fedora)
            echo "🔧 Installing build dependencies (Fedora)..."
            dnf install -y make automake gcc gcc-c++ kernel-devel redhat-rpm-config
            dnf install -y gcc openssl-devel bzip2-devel libffi-devel zlib-devel \
                readline-devel sqlite-devel wget xz-devel tk-devel ncurses-devel \
                libuuid-devel libxml2-devel xmlsec1-devel
            install_python_from_source
            ;;
        suse|opensuse*)
            echo "🔧 Installing build dependencies (SUSE)..."
            zypper refresh
            zypper install -y gcc make wget curl libopenssl-devel libffi-devel \
                libbz2-devel zlib-devel readline-devel sqlite3-devel ncurses-devel \
                tk-devel xz-devel libxml2-devel lzma-devel
            install_python_from_source
            ;;
        arch)
            echo "🔧 Installing build dependencies (Arch)..."
            pacman -Sy --noconfirm base-devel wget curl zlib libffi openssl tk
            install_python_from_source
            ;;
        *)
            echo "❌ Unsupported distribution."
            exit 1
            ;;
    esac
}

# Check or install Python 3.10
if command -v python3.10 >/dev/null 2>&1; then
    echo "✅ Python 3.10 already installed at $(command -v python3.10)"
    PYTHON_BIN=$(command -v python3.10)
else
    echo "🐍 Python 3.10 not found. Installing..."
    install_python
    PYTHON_BIN="/usr/local/bin/python3.10"
    if ! [ -x "$PYTHON_BIN" ]; then
        echo "❌ Python 3.10 installation failed."
        exit 1
    fi
fi

# Ensure pip is working
$PYTHON_BIN -m ensurepip --upgrade || {
    echo "❌ Failed to install pip for Python 3.10."
    exit 1
}
$PYTHON_BIN -m pip install --upgrade pip

# Setup project directory
mkdir -p "$PROJECT_DIR"
cd "$PROJECT_DIR"

# Create and activate virtual environment
echo "🐍 Creating virtual environment in $PROJECT_DIR/venv"
$PYTHON_BIN -m venv venv
if [ ! -f venv/bin/activate ]; then
    echo "❌ Failed to create virtual environment."
    exit 1
fi

source venv/bin/activate

# Install dependencies
if [ -f "requirements.txt" ]; then
    echo "📦 Installing dependencies..."
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

# Create launch script
cat << EOF > "$PROJECT_DIR/run_bible.sh"
#!/bin/bash
cd "$PROJECT_DIR" || exit 1
source "$PROJECT_DIR/venv/bin/activate"
python -m bible.main
EOF
chmod +x "$PROJECT_DIR/run_bible.sh"

# Create symlinks
mkdir -p "$REAL_HOME/.local/bin"
ln -sf "$PROJECT_DIR/run_bible.sh" "$REAL_HOME/.local/bin/bible"
echo "🔗 You can now run the Bible app by typing: bible"

if [ -w /usr/local/bin ]; then
    ln -sf "$PROJECT_DIR/run_bible.sh" /usr/local/bin/bible
    echo "🔗 Also symlinked globally: /usr/local/bin/bible"
else
    echo "⚠️ Cannot write to /usr/local/bin. Run manually if needed:"
    echo "    sudo ln -sf \"$PROJECT_DIR/run_bible.sh\" /usr/local/bin/bible"
fi
