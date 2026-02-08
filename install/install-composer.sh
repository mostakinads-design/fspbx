#!/bin/bash

# FS PBX Composer Installation Script
# This script installs Composer and handles PHP extension requirements

set -e

# Color codes for output
RED='\e[31m'
GREEN='\e[32m'
YELLOW='\e[33m'
BLUE='\e[34m'
NC='\e[0m'

print_success() {
    echo -e "${GREEN}✓ $1${NC}"
}

print_error() {
    echo -e "${RED}✗ $1${NC}"
}

print_warning() {
    echo -e "${YELLOW}⚠ $1${NC}"
}

print_info() {
    echo -e "${BLUE}ℹ $1${NC}"
}

print_header() {
    echo ""
    echo -e "${BLUE}========================================${NC}"
    echo -e "${BLUE}$1${NC}"
    echo -e "${BLUE}========================================${NC}"
}

# Auto-detect installation directory if not set
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
INSTALL_DIR="${INSTALL_DIR:-$(dirname "$SCRIPT_DIR")}"

print_header "Composer Installation"
print_info "Installation Directory: $INSTALL_DIR"

# Check if Composer is already installed
if command -v composer >/dev/null 2>&1; then
    COMPOSER_VERSION=$(composer --version 2>/dev/null | cut -d " " -f 3 || echo "unknown")
    print_info "Composer is already installed (version: $COMPOSER_VERSION)"
    
    # Ask if user wants to reinstall
    read -p "Do you want to reinstall Composer? (y/N): " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        print_success "Skipping Composer installation"
        exit 0
    fi
fi

# Install Composer
print_info "Downloading Composer installer..."

EXPECTED_CHECKSUM="$(wget -q -O - https://composer.github.io/installer.sig)"
php -r "copy('https://getcomposer.org/installer', 'composer-setup.php');"
ACTUAL_CHECKSUM="$(php -r "echo hash_file('sha384', 'composer-setup.php');")"

if [ "$EXPECTED_CHECKSUM" != "$ACTUAL_CHECKSUM" ]; then
    print_error "Composer installer checksum mismatch"
    rm composer-setup.php
    exit 1
fi

print_success "Composer installer verified"

print_info "Installing Composer..."
php composer-setup.php --quiet
RESULT=$?
rm composer-setup.php

if [ $RESULT -eq 0 ]; then
    mv composer.phar /usr/local/bin/composer
    chmod +x /usr/local/bin/composer
    print_success "Composer installed successfully"
    
    # Verify installation
    COMPOSER_VERSION=$(composer --version 2>/dev/null | cut -d " " -f 3 || echo "unknown")
    print_info "Installed version: $COMPOSER_VERSION"
else
    print_error "Failed to install Composer"
    exit 1
fi

# Check required PHP extensions for Laravel
print_header "Checking PHP Extensions for Laravel 12"

REQUIRED_EXTENSIONS=(
    "ctype"
    "curl"
    "dom"
    "fileinfo"
    "filter"
    "hash"
    "mbstring"
    "openssl"
    "pcre"
    "pdo"
    "session"
    "tokenizer"
    "xml"
    "zip"
)

MISSING_EXTENSIONS=()

for ext in "${REQUIRED_EXTENSIONS[@]}"; do
    if php -m | grep -qi "^$ext$"; then
        print_success "Extension '$ext' is available"
    else
        print_warning "Extension '$ext' is MISSING"
        MISSING_EXTENSIONS+=("$ext")
    fi
done

if [ ${#MISSING_EXTENSIONS[@]} -gt 0 ]; then
    print_warning "Some required PHP extensions are missing"
    print_info "Missing extensions: ${MISSING_EXTENSIONS[*]}"
    echo ""
    print_info "To install missing extensions, run:"
    
    # Detect PHP version
    PHP_VERSION=$(php -r "echo PHP_MAJOR_VERSION.'.'.PHP_MINOR_VERSION;")
    
    for ext in "${MISSING_EXTENSIONS[@]}"; do
        case "$ext" in
            "zip")
                echo "  sudo apt-get install -y php${PHP_VERSION}-zip"
                ;;
            "xml"|"dom")
                echo "  sudo apt-get install -y php${PHP_VERSION}-xml"
                ;;
            "mbstring")
                echo "  sudo apt-get install -y php${PHP_VERSION}-mbstring"
                ;;
            "curl")
                echo "  sudo apt-get install -y php${PHP_VERSION}-curl"
                ;;
            "pdo")
                echo "  sudo apt-get install -y php${PHP_VERSION}-pgsql"
                ;;
            *)
                echo "  sudo apt-get install -y php${PHP_VERSION}-${ext}"
                ;;
        esac
    done
    
    echo ""
    print_warning "Please install the missing extensions and run this script again"
    echo ""
    print_info "Alternatively, you can proceed with installation and use"
    print_info "composer install --ignore-platform-reqs (not recommended)"
    exit 1
fi

print_success "All required PHP extensions are available"

# If we're in the installation directory, offer to install dependencies
if [ -f "$INSTALL_DIR/composer.json" ]; then
    print_header "Install Composer Dependencies"
    
    read -p "Do you want to install Composer dependencies now? (Y/n): " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Nn]$ ]]; then
        cd "$INSTALL_DIR"
        
        print_info "Installing Composer dependencies..."
        print_info "This may take several minutes..."
        
        # Install dependencies with optimization for production
        composer install --no-dev --prefer-dist --optimize-autoloader --no-progress --no-interaction
        
        if [ $? -eq 0 ]; then
            print_success "Composer dependencies installed successfully"
        else
            print_error "Failed to install Composer dependencies"
            echo ""
            print_info "You can try running manually:"
            echo "  cd $INSTALL_DIR"
            echo "  composer install --no-dev --prefer-dist --optimize-autoloader"
            echo ""
            print_info "Or ignore platform requirements (not recommended):"
            echo "  composer install --ignore-platform-reqs"
            exit 1
        fi
    fi
fi

print_success "Composer installation complete!"
