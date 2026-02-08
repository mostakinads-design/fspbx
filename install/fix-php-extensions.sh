#!/bin/bash

# FS PBX PHP Extension Troubleshooting Script
# This script helps diagnose and fix PHP extension issues

set +e  # Don't exit on error

# Color codes
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

print_header "PHP Extension Troubleshooting Tool"

# Check if running as root
if [ "$EUID" -ne 0 ]; then 
    print_warning "This script should be run as root for best results"
    print_info "Run: sudo bash install/fix-php-extensions.sh"
fi

# Detect PHP version
print_header "PHP Configuration"

if command -v php >/dev/null 2>&1; then
    PHP_VERSION=$(php -r "echo PHP_MAJOR_VERSION.'.'.PHP_MINOR_VERSION;")
    print_success "PHP is installed"
    print_info "Version: $(php -v | head -n 1)"
    print_info "Binary: $(which php)"
else
    print_error "PHP is NOT installed!"
    exit 1
fi

# Show PHP configuration files
print_header "PHP Configuration Files"

print_info "Configuration files being used:"
php --ini

# Check critical extensions
print_header "Required Extensions Status"

REQUIRED_EXTENSIONS=("zip" "xml" "mbstring" "curl" "pdo" "pgsql" "gd" "bcmath" "intl" "soap")
MISSING_EXTENSIONS=()

for ext in "${REQUIRED_EXTENSIONS[@]}"; do
    if php -m 2>/dev/null | grep -qi "^${ext}$"; then
        print_success "Extension '$ext' is loaded"
    else
        print_error "Extension '$ext' is MISSING"
        MISSING_EXTENSIONS+=("$ext")
    fi
done

# Show all loaded extensions
print_header "All Loaded Extensions"
print_info "Total extensions loaded: $(php -m | wc -l)"
php -m | head -20
echo "... (showing first 20 extensions)"

# If extensions are missing, provide fix commands
if [ ${#MISSING_EXTENSIONS[@]} -gt 0 ]; then
    print_header "How to Fix Missing Extensions"
    
    print_error "Missing extensions: ${MISSING_EXTENSIONS[*]}"
    echo ""
    print_info "To install missing extensions, run these commands:"
    echo ""
    
    for ext in "${MISSING_EXTENSIONS[@]}"; do
        case "$ext" in
            "xml"|"dom")
                echo "  sudo apt-get install -y php${PHP_VERSION}-xml"
                ;;
            "pdo"|"pgsql")
                echo "  sudo apt-get install -y php${PHP_VERSION}-pgsql"
                ;;
            *)
                echo "  sudo apt-get install -y php${PHP_VERSION}-${ext}"
                ;;
        esac
    done
    
    echo ""
    echo "  sudo systemctl restart php${PHP_VERSION}-fpm"
    echo ""
    
    print_header "Quick Fix Option"
    print_info "If you have multiple PHP versions causing conflicts, run:"
    echo ""
    echo "  # Remove old PHP versions"
    echo "  sudo apt-get purge -y php8.1* php8.2*"
    echo "  sudo apt-get autoremove -y"
    echo ""
    echo "  # Reinstall PHP 8.3 with all extensions"
    echo "  sudo apt-get update"
    echo "  sudo apt-get install -y \\"
    echo "    php8.3 php8.3-cli php8.3-fpm \\"
    echo "    php8.3-zip php8.3-xml php8.3-mbstring php8.3-curl \\"
    echo "    php8.3-pgsql php8.3-gd php8.3-bcmath php8.3-intl php8.3-soap"
    echo ""
    echo "  # Set PHP 8.3 as default"
    echo "  sudo update-alternatives --set php /usr/bin/php8.3"
    echo ""
    echo "  # Restart PHP-FPM"
    echo "  sudo systemctl restart php8.3-fpm"
    echo ""
    
else
    print_header "Status: All Required Extensions Present"
    print_success "All required PHP extensions are loaded!"
    print_success "You can proceed with Composer installation"
fi

# Check if composer is installed
print_header "Composer Status"

if command -v composer >/dev/null 2>&1; then
    print_success "Composer is installed"
    print_info "Version: $(composer --version 2>/dev/null | cut -d ' ' -f 3)"
    
    # Test composer
    print_info "Testing Composer platform requirements..."
    composer check-platform-reqs 2>&1 | head -10
else
    print_warning "Composer is NOT installed"
    print_info "Run: sudo bash install/install-composer.sh"
fi

# Final recommendations
print_header "Next Steps"

if [ ${#MISSING_EXTENSIONS[@]} -eq 0 ]; then
    print_success "✓ System is ready for Composer installation"
    echo ""
    print_info "To install dependencies, run:"
    echo "  cd /var/www/fspbx  # or your installation path"
    echo "  composer install --no-dev --prefer-dist --optimize-autoloader"
else
    print_error "Please install the missing extensions first"
    echo ""
    print_info "After installing extensions:"
    echo "  1. Restart PHP-FPM: sudo systemctl restart php${PHP_VERSION}-fpm"
    echo "  2. Run this script again to verify"
    echo "  3. Then run composer install"
fi

print_header "Troubleshooting Complete"
