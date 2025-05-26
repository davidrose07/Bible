#!/bin/bash

OS_ID=$(grep '^ID=' /etc/os-release | cut -d= -f2 | tr -d '"')

case "$OS_ID" in
    debian|ubuntu)
        source ./debian.sh
        ;;
    fedora)
        source ./fedora.sh
        ;;
    opensuse*|suse)
        source ./suse.sh
        ;;
    *)
        echo "Unsupported OS: $OS_ID"
        exit 1
        ;;
esac
