#!/bin/bash

# FS PBX Requirements Checker
# This script checks if all required dependencies are installed

set +e  # Don't exit on error, we want to check everything

# Color codes for output
RED='\e[31m'
GREEN='\e[32m'
YELLOW='\e[33m'
BLUE='\e[34m'
NC='\e[0m' # No Color

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

# Track if we have any errors
HAS_ERRORS=0
HAS_WARNINGS=0

print_header "FS PBX System Requirements Check"

# Check if running as root
if [ "$EUID" -ne 0 ]; then 
    print_error "This script must be run as root (use sudo)"
    HAS_ERRORS=1
fi

# Check OS
print_header "Operating System Check"
if [ -f /etc/os-release ]; then
    . /etc/os-release
    print_info "OS: $NAME $VERSION"
    
    if [[ "$ID" == "debian" ]] && [[ "$VERSION_ID" =~ ^(12|13)$ ]]; then
        print_success "Supported Debian version detected"
    else
        print_warning "This script is designed for Debian 12 or 13. Your OS: $ID $VERSION_ID"
        HAS_WARNINGS=1
    fi
else
    print_error "Cannot detect OS version"
    HAS_ERRORS=1
fi

# Check system resources
print_header "System Resources Check"

# Check RAM
TOTAL_RAM=$(free -m | awk '/^Mem:/{print $2}')
if [ "$TOTAL_RAM" -ge 4000 ]; then
    print_success "RAM: ${TOTAL_RAM}MB (minimum 4GB recommended)"
else
    print_warning "RAM: ${TOTAL_RAM}MB (minimum 4GB recommended, current may be insufficient)"
    HAS_WARNINGS=1
fi

# Check disk space
DISK_SPACE=$(df -BG / | awk 'NR==2 {print $4}' | sed 's/G//')
if [ "$DISK_SPACE" -ge 30 ]; then
    print_success "Disk Space: ${DISK_SPACE}GB available (minimum 30GB recommended)"
else
    print_warning "Disk Space: ${DISK_SPACE}GB available (minimum 30GB recommended)"
    HAS_WARNINGS=1
fi

# Check required commands
print_header "Required System Commands"

REQUIRED_COMMANDS="wget curl git apt-get systemctl"
for cmd in $REQUIRED_COMMANDS; do
    if command -v $cmd >/dev/null 2>&1; then
        print_success "$cmd is installed"
    else
        print_error "$cmd is NOT installed"
        HAS_ERRORS=1
    fi
done

# Check PHP
print_header "PHP Check"

if command -v php >/dev/null 2>&1; then
    PHP_VERSION=$(php -v | head -n 1 | cut -d " " -f 2 | cut -d "." -f 1,2)
    print_info "PHP Version: $PHP_VERSION"
    
    if [[ $(echo "$PHP_VERSION >= 8.3" | bc -l) -eq 1 ]]; then
        print_success "PHP version 8.3+ detected"
    else
        print_error "PHP 8.3 or higher is required (current: $PHP_VERSION)"
        HAS_ERRORS=1
    fi
else
    print_error "PHP is NOT installed"
    print_info "Will be installed during setup"
fi

# Check PHP Extensions (if PHP is installed)
if command -v php >/dev/null 2>&1; then
    print_header "Required PHP Extensions Check"
    
    REQUIRED_EXTENSIONS=(
        "curl"
        "mbstring"
        "xml"
        "zip"
        "pgsql"
        "pdo"
        "gd"
        "iconv"
        "simplexml"
        "fileinfo"
        "tokenizer"
        "openssl"
        "json"
    )
    
    for ext in "${REQUIRED_EXTENSIONS[@]}"; do
        if php -m | grep -qi "^$ext$"; then
            print_success "PHP extension '$ext' is installed"
        else
            print_error "PHP extension '$ext' is NOT installed"
            HAS_ERRORS=1
        fi
    done
    
    # Check for optional but recommended extensions
    print_header "Recommended PHP Extensions Check"
    
    RECOMMENDED_EXTENSIONS=(
        "opcache"
        "redis"
        "imagick"
        "imap"
        "ldap"
        "inotify"
    )
    
    for ext in "${RECOMMENDED_EXTENSIONS[@]}"; do
        if php -m | grep -qi "^$ext$"; then
            print_success "PHP extension '$ext' is installed"
        else
            print_warning "PHP extension '$ext' is not installed (recommended)"
            HAS_WARNINGS=1
        fi
    done
fi

# Check Composer
print_header "Composer Check"

if command -v composer >/dev/null 2>&1; then
    COMPOSER_VERSION=$(composer --version 2>/dev/null | cut -d " " -f 3)
    print_success "Composer is installed (version: $COMPOSER_VERSION)"
else
    print_info "Composer is NOT installed (will be installed during setup)"
fi

# Check PostgreSQL
print_header "PostgreSQL Check"

if command -v psql >/dev/null 2>&1; then
    PG_VERSION=$(psql --version | cut -d " " -f 3)
    print_success "PostgreSQL is installed (version: $PG_VERSION)"
else
    print_info "PostgreSQL is NOT installed (will be installed during setup)"
fi

# Check Nginx
print_header "Nginx Check"

if command -v nginx >/dev/null 2>&1; then
    NGINX_VERSION=$(nginx -v 2>&1 | cut -d "/" -f 2)
    print_success "Nginx is installed (version: $NGINX_VERSION)"
else
    print_info "Nginx is NOT installed (will be installed during setup)"
fi

# Check Node.js and npm
print_header "Node.js and npm Check"

if command -v node >/dev/null 2>&1; then
    NODE_VERSION=$(node --version)
    print_success "Node.js is installed (version: $NODE_VERSION)"
else
    print_info "Node.js is NOT installed (will be installed during setup)"
fi

if command -v npm >/dev/null 2>&1; then
    NPM_VERSION=$(npm --version)
    print_success "npm is installed (version: $NPM_VERSION)"
else
    print_info "npm is NOT installed (will be installed during setup)"
fi

# Summary
print_header "Requirements Check Summary"

if [ $HAS_ERRORS -eq 0 ] && [ $HAS_WARNINGS -eq 0 ]; then
    print_success "All requirements are met! You can proceed with installation."
    exit 0
elif [ $HAS_ERRORS -eq 0 ]; then
    print_warning "Some recommended requirements are not met, but installation can proceed."
    echo ""
    print_info "You may want to address the warnings above before installing."
    exit 0
else
    print_error "Some critical requirements are not met."
    echo ""
    print_info "Please address the errors above before proceeding with installation."
    echo ""
    print_info "To install missing dependencies, you can run:"
    echo ""
    echo "  sudo apt-get update"
    echo "  sudo apt-get install -y wget curl git bc"
    echo ""
    print_info "For PHP and extensions, the installation script will handle these."
    exit 1
fi
