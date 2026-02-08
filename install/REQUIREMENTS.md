# FS PBX System Requirements

## Overview

This document outlines the system requirements for installing and running FS PBX with Laravel 12 and Filament 5.

## Minimum System Requirements

### Hardware
- **RAM**: 4GB minimum (8GB+ recommended for production)
- **Disk Space**: 30GB minimum (SSD/NVMe recommended for production)
- **CPU**: 2 cores minimum (4+ cores recommended for production)

### Operating System
- **Supported**: Debian 12 (Bookworm) or Debian 13 (Trixie)
- **Architecture**: x86_64 (amd64) or ARM64

## Software Requirements

### PHP Requirements
- **Version**: PHP 8.3 or higher (required for Filament 5 and Laravel 12)
- **Required Extensions**:
  - `php-cli` - Command line interface
  - `php-fpm` - FastCGI Process Manager
  - `php-curl` - cURL support
  - `php-mbstring` - Multi-byte string support
  - `php-xml` - XML support
  - `php-zip` - ZIP archive support
  - `php-pgsql` - PostgreSQL support
  - `php-pdo` - PHP Data Objects
  - `php-gd` - Image processing
  - `php-bcmath` - BC Math support
  - `php-intl` - Internationalization support
  - `php-soap` - SOAP protocol support
  - `php-iconv` - Character encoding conversion
  - `php-simplexml` - SimpleXML support
  - `php-fileinfo` - File information support
  - `php-tokenizer` - Tokenizer support
  - `php-openssl` - OpenSSL support
  - `php-json` - JSON support

- **Recommended Extensions**:
  - `php-opcache` - Opcode cache for better performance
  - `php-redis` - Redis support
  - `php-imagick` - ImageMagick support
  - `php-imap` - IMAP support
  - `php-ldap` - LDAP support
  - `php-inotify` - Inotify support

### Database
- **PostgreSQL**: Version 15, 16, 17, or 18
  - Debian 12: PostgreSQL 17
  - Debian 13: PostgreSQL 18

### Web Server
- **Nginx**: Latest stable version
- **Alternative**: Apache 2.4+ (with mod_rewrite)

### Other Dependencies
- **Composer**: Latest stable version (2.x)
- **Node.js**: Version 18.x or higher
- **npm**: Latest stable version
- **Git**: For version control
- **Supervisor**: For managing background processes
- **Redis**: For caching and queues (recommended)

## Laravel 12 Specific Requirements

Laravel 12 requires:
- PHP 8.3+ (minimum for optimal compatibility with Filament 5)
- BCMath PHP Extension
- Ctype PHP Extension
- cURL PHP Extension
- DOM PHP Extension
- Fileinfo PHP Extension
- Filter PHP Extension
- Hash PHP Extension
- Mbstring PHP Extension
- OpenSSL PHP Extension
- PCRE PHP Extension
- PDO PHP Extension
- Session PHP Extension
- Tokenizer PHP Extension
- XML PHP Extension
- ZIP PHP Extension

## Filament 5 Specific Requirements

Filament (v3.x) requires:
- Laravel 10 or 11 (but works with Laravel 12)
- PHP 8.3+ (recommended for optimal performance)
- All Laravel PHP extensions

## Network Requirements

### Ports
- **HTTP**: 80 (or custom)
- **HTTPS**: 443 (or custom)
- **PostgreSQL**: 5432
- **FreeSwitch ESL**: 8021
- **Redis**: 6379 (if using Redis)

### Firewall
Ensure the following ports are accessible:
- HTTP/HTTPS for web access
- SIP ports for VoIP functionality
- RTP ports for media streaming

## Pre-Installation Checks

Before installing FS PBX, run the requirements checker:

```bash
sudo bash install/check_requirements.sh
```

This script will verify:
- Operating system compatibility
- System resources (RAM, disk space)
- Required commands (wget, curl, git, etc.)
- PHP version and extensions
- Database availability
- Web server status

## Installation Methods

### Method 1: Automated Installation (Recommended)

```bash
# Check requirements first
sudo bash install/check_requirements.sh

# Install to default location (/var/www/fspbx)
wget -O- https://raw.githubusercontent.com/nemerald-voip/fspbx/main/install/install-fspbx.sh | sudo bash
```

### Method 2: Custom Directory Installation

```bash
# Check requirements first
sudo bash install/check_requirements.sh

# Install to custom location
wget https://raw.githubusercontent.com/nemerald-voip/fspbx/main/install/install-fspbx.sh
chmod +x install-fspbx.sh
sudo ./install-fspbx.sh /var/www/pbx
```

### Method 3: Manual Installation

```bash
# 1. Clone repository
git clone https://github.com/nemerald-voip/fspbx.git /var/www/fspbx
cd /var/www/fspbx

# 2. Check requirements
sudo bash install/check_requirements.sh

# 3. Run installation
sudo bash install/install.sh
```

## Composer Installation

If you encounter Composer issues during installation:

```bash
# Install Composer separately
sudo bash install/install-composer.sh

# Or manually install dependencies
cd /var/www/fspbx
composer install --no-dev --prefer-dist --optimize-autoloader

# If you have missing PHP extensions
sudo apt-get install -y php8.2-zip php8.2-xml php8.2-mbstring php8.2-curl

# As a last resort (not recommended for production)
composer install --ignore-platform-reqs
```

## Troubleshooting Common Issues

### Issue: "ext-zip is missing"

**Solution:**
```bash
# For PHP 8.3 (recommended)
sudo apt-get install -y php8.3-zip

# Restart PHP-FPM
sudo systemctl restart php8.3-fpm
```

### Issue: "Composer dependencies installation failed"

**Solutions:**

1. **Check PHP extensions:**
   ```bash
   php -m | grep -i zip
   php -m | grep -i xml
   php -m | grep -i mbstring
   ```

2. **Install missing extensions:**
   ```bash
   sudo apt-get update
   sudo apt-get install -y php8.3-zip php8.3-xml php8.3-mbstring php8.3-curl
   ```

3. **Verify Composer:**
   ```bash
   composer diagnose
   ```

4. **Try with platform requirements check:**
   ```bash
   composer install --ignore-platform-reqs
   ```

### Issue: "Insufficient RAM or disk space"

**Solution:**
- Increase server resources
- Use swap space as temporary solution:
  ```bash
  sudo fallocate -l 4G /swapfile
  sudo chmod 600 /swapfile
  sudo mkswap /swapfile
  sudo swapon /swapfile
  ```

### Issue: "Permission denied" errors

**Solution:**
```bash
# Fix ownership
sudo chown -R www-data:www-data /var/www/fspbx

# Fix permissions
sudo chmod -R 755 /var/www/fspbx
sudo chmod -R 775 /var/www/fspbx/storage
sudo chmod -R 775 /var/www/fspbx/bootstrap/cache
```

## Performance Optimization

### PHP Configuration

Recommended PHP settings in `/etc/php/8.3/fpm/php.ini`:

```ini
memory_limit = 512M
max_execution_time = 300
upload_max_filesize = 80M
post_max_size = 80M
max_input_vars = 8000
session.gc_maxlifetime = 7200
```

### OPcache Configuration

Enable OPcache in `/etc/php/8.3/fpm/conf.d/10-opcache.ini`:

```ini
opcache.enable=1
opcache.memory_consumption=256
opcache.interned_strings_buffer=16
opcache.max_accelerated_files=10000
opcache.revalidate_freq=2
opcache.fast_shutdown=1
```

### Composer Optimization

```bash
# Optimize autoloader
composer dump-autoload --optimize

# Clear and cache Laravel config
php artisan config:cache
php artisan route:cache
php artisan view:cache
```

## Security Considerations

1. **Keep system updated:**
   ```bash
   sudo apt-get update && sudo apt-get upgrade
   ```

2. **Use HTTPS with valid SSL certificate:**
   - Let's Encrypt (recommended for production)
   - Self-signed certificate (development only)

3. **Configure firewall:**
   ```bash
   sudo ufw enable
   sudo ufw allow 80/tcp
   sudo ufw allow 443/tcp
   sudo ufw allow 22/tcp
   ```

4. **Secure PostgreSQL:**
   - Use strong passwords
   - Restrict network access
   - Regular backups

5. **Keep Composer dependencies updated:**
   ```bash
   composer audit
   composer update
   ```

## Additional Resources

- [Laravel 12 Documentation](https://laravel.com/docs/12.x)
- [Filament Documentation](https://filamentphp.com/docs)
- [Installation Paths Guide](INSTALLATION_PATHS.md)
- [Upgrade Guide](../UPGRADE.md)
- [PostgreSQL Documentation](https://www.postgresql.org/docs/)
- [Nginx Documentation](https://nginx.org/en/docs/)

## Support

If you encounter issues not covered in this document:

1. Check application logs: `/var/www/fspbx/storage/logs/laravel.log`
2. Check PHP-FPM logs: `/var/log/php8.3-fpm.log`
3. Check Nginx logs: `/var/log/nginx/error.log`
4. Review this requirements document
5. Contact support for assistance
