#!/bin/bash

# Set error handling
set -e

# Function to print success message
print_success() {
    echo -e "\e[32m$1 \e[0m"  # Green text
}

# Function to print error message
print_error() {
    echo -e "\e[31m$1 \e[0m"  # Red text
}

# Function to display usage
usage() {
    echo "Usage: $0 [INSTALL_DIR]"
    echo ""
    echo "Arguments:"
    echo "  INSTALL_DIR  - Installation directory (default: /var/www/fspbx)"
    echo ""
    echo "Examples:"
    echo "  $0                    # Install to /var/www/fspbx"
    echo "  $0 /var/www/pbx       # Install to /var/www/pbx"
    echo "  $0 /opt/fspbx         # Install to /opt/fspbx"
    exit 1
}

# Detect OS codename

OS_CODENAME=$(lsb_release -sc 2>/dev/null || echo "")

echo "Detected OS_CODENAME=$OS_CODENAME"

# Ensure Git is installed
if ! command -v git &> /dev/null; then
    apt update && apt install -y git
    print_success "Git installed successfully."
fi

# Ensure Curl is installed
if ! command -v curl &> /dev/null; then
    apt update && apt install -y curl
    print_success "Curl installed successfully."
fi

# Ensure Sudo is installed
if ! command -v sudo &> /dev/null; then
    apt update && apt install -y sudo
    print_success "Sudo installed successfully."
fi

# Define variables - Allow custom installation directory
INSTALL_DIR="${1:-/var/www/fspbx}"  # Use first argument or default to /var/www/fspbx
PUBLIC_DIR="$INSTALL_DIR/public"
BACKUP_DIR="${INSTALL_DIR}_backup_$(date +%Y%m%d_%H%M%S)"
export PHP_VERSION="8.3"
export FREESWITCH_VERSION="v1.10"
export INSTALL_DIR  # Export for use by sub-scripts

#Set Postgres Version
if [[ "$OS_CODENAME" == "bookworm" ]]; then
    export POSTGRESQL_VERSION="17"
fi

if [[ "$OS_CODENAME" == "trixie" ]]; then
    export POSTGRESQL_VERSION="18"
fi

# Fetch the latest FusionPBX version from GitHub API
print_success "Fetching the latest FusionPBX release version..."
FUSIONPBX_VERSION=$(curl -s https://api.github.com/repos/nemerald-voip/fusionpbx/releases/latest | grep "tag_name" | cut -d '"' -f 4)

if [[ -z "$FUSIONPBX_VERSION" ]]; then
    print_error "Failed to fetch FusionPBX version. Exiting..."
    exit 1
fi

print_success "Latest FusionPBX version: $FUSIONPBX_VERSION"

# Construct the download URL
FUSIONPBX_RELEASE="https://github.com/nemerald-voip/fusionpbx/archive/refs/tags/${FUSIONPBX_VERSION}.tar.gz"

# Display installation directory
print_success "==========================================="
print_success "Installation Directory: $INSTALL_DIR"
print_success "==========================================="

# Backup existing installation if the directory is not empty
if [ -d "$INSTALL_DIR" ] && [ "$(ls -A $INSTALL_DIR 2>/dev/null)" ]; then
    print_success "Backing up existing installation to $BACKUP_DIR..."
    mv $INSTALL_DIR $BACKUP_DIR
    print_success "Backup completed: $BACKUP_DIR"
fi

# Clone FS PBX repository
print_success "Cloning FS PBX repository..."
git clone --depth 1 https://github.com/nemerald-voip/fspbx.git $INSTALL_DIR
print_success "FS PBX repository cloned successfully."

# Ensure public directory exists
mkdir -p $PUBLIC_DIR

# Download the specified FusionPBX release
print_success "Downloading FusionPBX v$FUSIONPBX_VERSION release..."
wget -O "$PUBLIC_DIR/fusionpbx-${FUSIONPBX_VERSION}.tar.gz" $FUSIONPBX_RELEASE

# Extract the FusionPBX archive
print_success "Extracting FusionPBX files..."
tar -xvzf "$PUBLIC_DIR/fusionpbx-${FUSIONPBX_VERSION}.tar.gz" -C $PUBLIC_DIR --strip-components=1
rm "$PUBLIC_DIR/fusionpbx-${FUSIONPBX_VERSION}.tar.gz"
print_success "FusionPBX v$FUSIONPBX_VERSION files extracted successfully."

# Run the FS PBX main installer script
print_success "Running FS PBX installation script..."
bash $INSTALL_DIR/install/install.sh
print_success "FS PBX installation completed successfully!"
