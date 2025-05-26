#!/bin/bash

# Constants
CERT_URL="https://clientdownload.catonetworks.com/public/certificates/CatoNetworksTrustedRootCA.cer"
CER_FILE="CatoNetworksTrustedRootCA.cer"
PEM_FILE="CatoNetworksTrustedRootCA.pem"
MINIKUBE_CERT_DIR="${HOME}/.minikube/certs"

# Print usage
usage() {
    cat <<EOF
Usage: $0 [OPTIONS]

Download, convert and optionally install the Cato Networks Root CA for minikube.

Options:
  -d, --download     Download the certificate only
  -c, --convert      Convert the .cer to .pem only
  -i, --install      Install the .pem into the minikube cert directory
  -f, --force        Force redownload and reconvert even if pem exists
  -h, --help         Show this help message

If no options are provided, performs download and convert.
Use -i to additionally install into minikube.
EOF
}

# Check dependencies
require_dep() {
    for dep in "$@"; do
        command -v "$dep" >/dev/null 2>&1 || {
            echo "Error: '$dep' not found in PATH. Aborting."
            exit 1
        }
    done
}

# Download the .cer file
download_cert() {
    echo "Downloading certificate..."
    curl -sSL -o "$CER_FILE" "$CERT_URL" || {
        echo "Error downloading certificate."
        exit 2
    }
}

# Convert to PEM
convert_cert() {
    echo "Converting $CER_FILE to $PEM_FILE..."
    openssl x509 -inform DER -in "$CER_FILE" -out "$PEM_FILE" || {
        echo "Error converting certificate."
        exit 3
    }
}

# Install PEM to minikube
install_pem() {
    echo "Installing $PEM_FILE to $MINIKUBE_CERT_DIR..."
    mkdir -p "$MINIKUBE_CERT_DIR"
    cp "$PEM_FILE" "$MINIKUBE_CERT_DIR/" || {
        echo "Error copying to minikube cert directory."
        exit 4
    }
    echo "Installed successfully."
}

# Cleanup .cer file
cleanup() {
    [ -f "$CER_FILE" ] && rm -f "$CER_FILE"
}

# Main
ACTION_DOWNLOAD=0
ACTION_CONVERT=0
ACTION_INSTALL=0
FORCE=0

# Option parsing (Bash 3.2 compatible)
while [ $# -gt 0 ]; do
    case "$1" in
        -d|--download) ACTION_DOWNLOAD=1 ;;
        -c|--convert) ACTION_CONVERT=1 ;;
        -i|--install) ACTION_INSTALL=1 ;;
        -f|--force) FORCE=1 ;;
        -h|--help) usage; exit 0 ;;
        *) echo "Unknown option: $1"; usage; exit 1 ;;
    esac
    shift
done

require_dep curl openssl

# Default: Download + Convert if no specific action
if [ "$ACTION_DOWNLOAD" = "0" ] && [ "$ACTION_CONVERT" = "0" ] && [ "$ACTION_INSTALL" = "0" ]; then
    ACTION_DOWNLOAD=1
    ACTION_CONVERT=1
fi

# Download
if [ "$ACTION_DOWNLOAD" = "1" ]; then
    if [ "$FORCE" = "1" ] || [ ! -f "$PEM_FILE" ]; then
        download_cert
    else
        echo "$PEM_FILE already exists. Use -f to force re-download."
    fi
fi

# Convert
if [ "$ACTION_CONVERT" = "1" ]; then
    if [ "$FORCE" = "1" ] || [ ! -f "$PEM_FILE" ]; then
        if [ ! -f "$CER_FILE" ]; then
            echo "Certificate file not found. Downloading first."
            download_cert
        fi
        convert_cert
        cleanup
    else
        echo "$PEM_FILE already exists. Use -f to force re-convert."
    fi
fi

# Install
if [ "$ACTION_INSTALL" = "1" ]; then
    if [ ! -f "$PEM_FILE" ]; then
        echo "$PEM_FILE not found. Downloading and converting first."
        download_cert
        convert_cert
        cleanup
    fi
    install_pem
fi
