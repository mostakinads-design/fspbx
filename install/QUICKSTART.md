# FS PBX Installation Quick Start Guide

## What's New

This installation package includes:

### ✅ PHP 8.3+ Required
- **Upgraded from PHP 8.2 to PHP 8.3**
- Required for optimal Filament 5 performance
- Includes all necessary extensions (zip, xml, mbstring, curl, etc.)

### ✅ Pre-Installation Checker
New script to verify your system before installation:
```bash
sudo bash install/check_requirements.sh
```

### ✅ Improved Composer Installation
Dedicated script with better error handling:
```bash
sudo bash install/install-composer.sh
```

### ✅ Better Error Messages
- Clear color-coded output
- Specific commands to fix issues
- Recovery instructions included

---

## Quick Installation (3 Methods)

### Method 1: Automated (Default Location)
```bash
# Check requirements first
wget https://raw.githubusercontent.com/nemerald-voip/fspbx/main/install/check_requirements.sh
sudo bash check_requirements.sh

# Install to /var/www/fspbx
wget -O- https://raw.githubusercontent.com/nemerald-voip/fspbx/main/install/install-fspbx.sh | sudo bash
```

### Method 2: Custom Directory
```bash
# Check requirements
sudo bash install/check_requirements.sh

# Install to /var/www/pbx (or any path)
wget https://raw.githubusercontent.com/nemerald-voip/fspbx/main/install/install-fspbx.sh
chmod +x install-fspbx.sh
sudo ./install-fspbx.sh /var/www/pbx
```

### Method 3: From Cloned Repository
```bash
# Clone repository
git clone https://github.com/nemerald-voip/fspbx.git /var/www/fspbx
cd /var/www/fspbx

# Check requirements
sudo bash install/check_requirements.sh

# Install
sudo bash install/install.sh
```

---

## Troubleshooting Common Issues

### ❌ Error: "ext-zip is missing"

**This is the most common error!**

**Symptoms:**
- Error message: `You can also run Composer with --ignore-platform-req=ext-zip`
- Composer fails during `composer install`
- References to `/etc/php/8.2/cli/conf.d/` (old PHP version)

**Fix:**
```bash
# 1. Ensure PHP 8.3 is installed and active
php --version  # Should show PHP 8.3.x

# 2. Install php-zip extension
sudo apt-get update
sudo apt-get install -y php8.3-zip

# 3. Restart PHP-FPM
sudo systemctl restart php8.3-fpm

# 4. Verify extension is loaded
php -m | grep zip

# 5. If still not showing, check all PHP CLI config
php --ini

# 6. Retry composer install
cd /var/www/fspbx  # or your installation path
composer install --no-dev --prefer-dist --optimize-autoloader
```

**Alternative fix if you have multiple PHP versions:**
```bash
# Remove old PHP versions
sudo apt-get purge -y php8.1* php8.2*
sudo apt-get autoremove -y

# Reinstall PHP 8.3 cleanly
sudo apt-get install -y php8.3 php8.3-zip php8.3-xml php8.3-mbstring php8.3-curl

# Set default PHP version
sudo update-alternatives --set php /usr/bin/php8.3

# Verify
php --version
php -m | grep -E "zip|xml|mbstring"
```

### ❌ Error: "Composer installation failed"

**Fix:**
```bash
# Install Composer separately
sudo bash install/install-composer.sh
```

### ❌ Error: "PHP version too low"

**Fix:**
```bash
# The installer will install PHP 8.3 automatically
# But if you need to verify:
php --version  # Should show 8.3.x
```

### ❌ Error: "Insufficient RAM or disk space"

**Fix:**
```bash
# Check resources
free -h           # Should show 4GB+ RAM
df -h /           # Should show 30GB+ available

# Add swap if needed (temporary)
sudo fallocate -l 4G /swapfile
sudo chmod 600 /swapfile
sudo mkswap /swapfile
sudo swapon /swapfile
```

---

## Post-Installation

### Access Filament Admin Panel
```
URL: https://your-domain.com/admin
```

### Create Admin User
```bash
cd /var/www/fspbx  # or your installation path
php artisan make:filament-user
```

### Verify Installation
```bash
# Check PHP version
php --version

# Check Laravel version
php artisan --version

# Check installed extensions
php -m | grep -E "zip|xml|mbstring|curl"
```

---

## System Requirements Summary

| Requirement | Minimum | Recommended |
|------------|---------|-------------|
| **OS** | Debian 12/13 | Debian 13 |
| **PHP** | 8.3 | 8.3+ |
| **RAM** | 4GB | 8GB+ |
| **Disk** | 30GB | 50GB+ SSD |
| **CPU** | 2 cores | 4+ cores |

### Required PHP Extensions
✓ curl, mbstring, xml, zip, pgsql, pdo, gd, bcmath, intl, soap, openssl, json, tokenizer

### Recommended
✓ opcache, redis, imagick, imap, ldap, inotify

---

## Getting Help

1. **Check logs:**
   ```bash
   tail -f /var/www/fspbx/storage/logs/laravel.log
   ```

2. **Read documentation:**
   - [REQUIREMENTS.md](REQUIREMENTS.md) - Complete requirements
   - [INSTALLATION_PATHS.md](INSTALLATION_PATHS.md) - Path configuration
   - [UPGRADE.md](../UPGRADE.md) - Upgrade guide

3. **Run diagnostics:**
   ```bash
   sudo bash install/check_requirements.sh
   php artisan about
   composer diagnose
   ```

4. **Contact support** if issues persist

---

## Key Files

| File | Purpose |
|------|---------|
| `check_requirements.sh` | Pre-flight system check |
| `install-composer.sh` | Composer installation |
| `install-fspbx.sh` | Main installer |
| `install.sh` | Core installation script |
| `REQUIREMENTS.md` | Detailed requirements |

---

## What Changed from Previous Version

- ✅ **PHP 8.3+ required** (was 8.2)
- ✅ **New pre-flight checker** for early error detection
- ✅ **Dedicated Composer installer** with extension validation
- ✅ **More PHP extensions** included by default
- ✅ **Dynamic PHP version** detection in scripts
- ✅ **Better error messages** with recovery steps
- ✅ **Path-agnostic** installation support
- ✅ **Comprehensive documentation** added

---

## Quick Commands Reference

```bash
# Check if system is ready
sudo bash install/check_requirements.sh

# Install Composer only
sudo bash install/install-composer.sh

# Install to custom location
sudo ./install-fspbx.sh /your/path

# Check PHP extensions
php -m

# Restart PHP-FPM
sudo systemctl restart php8.3-fpm

# Clear Laravel caches
php artisan optimize:clear

# Create admin user
php artisan make:filament-user
```

---

**Ready to install?** Start with `sudo bash install/check_requirements.sh` to verify your system!
