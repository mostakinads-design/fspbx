# Installation Directory Guide

## Overview

The FS PBX installation scripts are now **path-agnostic**, meaning you can install the system in any directory, not just `/var/www/fspbx`.

## Supported Installation Paths

You can install FS PBX in any location on your system:
- `/var/www/fspbx` (default)
- `/var/www/pbx`
- `/opt/fspbx`
- Any custom path of your choice

## Installation Methods

### Method 1: Default Installation (to /var/www/fspbx)

```bash
wget -O- https://raw.githubusercontent.com/nemerald-voip/fspbx/main/install/install-fspbx.sh | bash
```

### Method 2: Custom Directory Installation

```bash
# Download the installation script
wget https://raw.githubusercontent.com/nemerald-voip/fspbx/main/install/install-fspbx.sh

# Make it executable
chmod +x install-fspbx.sh

# Install to your custom directory
./install-fspbx.sh /var/www/pbx
```

### Method 3: Install from Cloned Repository

```bash
# Clone to your desired location
git clone https://github.com/nemerald-voip/fspbx.git /var/www/pbx

# Navigate to the install directory
cd /var/www/pbx/install

# Run the installation script (it will auto-detect the installation directory)
sudo bash install.sh
```

## How It Works

### Automatic Path Detection

The installation scripts automatically detect the installation directory using one of these methods:

1. **Exported INSTALL_DIR variable**: If you set `INSTALL_DIR` environment variable, it will be used
2. **Script parameter**: Pass the directory as the first parameter to `install-fspbx.sh`
3. **Auto-detection**: The script detects its own location and uses the parent directory

### Updated Components

The following files have been updated to support path-agnostic installation:

#### PHP Files (using Laravel's `base_path()`)
- `app/Console/Commands/BackupApp.php`
- `app/Console/Commands/FSPBXInitialDBSeed.php`
- `app/Console/Commands/ProvisioningLinkTemplates.php`
- `app/Console/Commands/Updates/*.php`

#### Installation Scripts
- `install/install-fspbx.sh` - Main installer with custom path support
- `install/install.sh` - Core installation script with auto-detection
- `install/install_cron_jobs.sh` - Cron job setup with dynamic paths

#### Configuration Templates
- `install/horizon.conf.template` - Horizon supervisor config template
- `install/fs-cdr-service.conf.template` - CDR service config template

## Examples

### Install to /var/www/pbx
```bash
./install-fspbx.sh /var/www/pbx
```

### Install to /opt/fspbx
```bash
./install-fspbx.sh /opt/fspbx
```

### Install with exported variable
```bash
export INSTALL_DIR=/var/www/my-custom-pbx
./install-fspbx.sh
```

## Updating an Existing Installation

After installation, updates work from any directory:

```bash
cd /path/to/your/fspbx  # Your actual installation path
git pull
php artisan app:update
```

## Important Notes

1. **Permissions**: Ensure your web server user (www-data) has appropriate permissions on the installation directory
2. **Nginx/Apache Configuration**: Update your web server configuration to point to the correct installation path
3. **Supervisor Services**: Supervisor configuration files are automatically generated with the correct paths
4. **Cron Jobs**: Cron jobs are automatically configured with your installation path

## Troubleshooting

### Check Installation Directory
You can always verify where your installation is located:

```bash
# From within the installation directory
php artisan tinker
>>> base_path()
```

### Update Cron Jobs
If you move the installation after initial setup:

```bash
cd /new/path/to/fspbx
sudo bash install/install_cron_jobs.sh
```

### Regenerate Supervisor Configs
If you move the installation:

```bash
# Process templates with new path
export INSTALL_DIR=/new/path/to/fspbx
cd $INSTALL_DIR/install
sudo bash -c "sed 's|__INSTALL_DIR__|$INSTALL_DIR|g' horizon.conf.template > /etc/supervisor/conf.d/horizon.conf"
sudo bash -c "sed 's|__INSTALL_DIR__|$INSTALL_DIR|g' fs-cdr-service.conf.template > /etc/supervisor/conf.d/fs-cdr-service.conf"
sudo supervisorctl reread
sudo supervisorctl update
```

## Migration Guide

If you have an existing installation at `/var/www/fspbx` and want to move it to `/var/www/pbx`:

```bash
# Stop services
sudo supervisorctl stop all
sudo systemctl stop nginx

# Move the installation
sudo mv /var/www/fspbx /var/www/pbx

# Update configurations
cd /var/www/pbx
export INSTALL_DIR=/var/www/pbx
sudo bash install/install_cron_jobs.sh

# Update supervisor configs
sudo bash -c "sed 's|__INSTALL_DIR__|/var/www/pbx|g' install/horizon.conf.template > /etc/supervisor/conf.d/horizon.conf"
sudo bash -c "sed 's|__INSTALL_DIR__|/var/www/pbx|g' install/fs-cdr-service.conf.template > /etc/supervisor/conf.d/fs-cdr-service.conf"
sudo supervisorctl reread
sudo supervisorctl update

# Update nginx configuration
sudo nano /etc/nginx/sites-available/fspbx
# Update root and fastcgi_param SCRIPT_FILENAME paths

# Restart services
sudo systemctl start nginx
sudo supervisorctl start all
```
