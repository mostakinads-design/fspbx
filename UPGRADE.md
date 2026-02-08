# Laravel 12 Upgrade Guide

## Overview

FS PBX has been upgraded from Laravel 10 to Laravel 12, bringing significant improvements in performance, security, and developer experience.

## What's New in Laravel 12

### PHP Requirements
- **Minimum PHP version**: 8.2 (upgraded from 8.1)
- Better type safety and modern PHP features

### Framework Updates
- Laravel Framework: 12.x
- Updated core dependencies:
  - Laravel Sanctum: 4.0
  - Laravel Horizon: 5.28
  - Laravel Fortify: 1.24
  - Laravel Tinker: 2.10
  - Laravel UI: 4.6
  
### Development Tools
- PHPUnit: 11.0 (upgraded from 9.x)
- Collision: 8.0 (improved error handling)
- Spatie Laravel Ignition: 2.8

### Third-Party Package Updates
- Inertia Laravel: 1.0
- Symfony Components: 7.0
- Spatie Laravel Query Builder: 6.0
- Scribe API Documentation: 5.0

## New Features

### Filament Admin Panel
A modern admin interface has been added using Filament 3.x:
- Accessible at `/admin`
- User management interface
- Extensible resource system
- Modern UI with Tailwind CSS

### Path-Agnostic Installation
The application can now be installed in any directory:
- Default: `/var/www/fspbx`
- Custom paths supported: `/var/www/pbx`, `/opt/fspbx`, etc.
- Automatic path detection in installation scripts
- Configuration templates for flexible deployment

## Breaking Changes

### Removed Dependencies
- **simplesoftwareio/simple-qrcode**: Removed due to incompatibility with Laravel 12's bacon/bacon-qr-code ^3.0 requirement
  - Impact: QR code generation functionality needs to be reimplemented
  - Alternative: Use bacon/bacon-qr-code directly or endroid/qr-code

### Configuration Changes
- **Sanctum**: `ignoreMigrations()` method behavior changed
- **PHPUnit**: Updated XML schema and configuration structure
- **Bootstrap**: Maintains Laravel 10-style bootstrap/app.php for backward compatibility

## Migration Steps

If you're upgrading an existing installation:

### 1. Backup Your Installation
```bash
# Create a backup
cd /path/to/your/fspbx
sudo php artisan app:backup
```

### 2. Update Dependencies
```bash
# Pull latest changes
git pull

# Update Composer dependencies
composer update

# Clear caches
php artisan config:clear
php artisan cache:clear
php artisan view:clear
php artisan route:clear
```

### 3. Run Migrations
```bash
php artisan migrate
```

### 4. Update Assets
```bash
npm install
npm run build
```

### 5. Restart Services
```bash
# Restart PHP-FPM
sudo systemctl restart php8.2-fpm

# Restart queue workers
php artisan queue:restart

# Restart Horizon
php artisan horizon:terminate
```

## Post-Upgrade Checklist

- [ ] Verify PHP version is 8.2 or higher: `php --version`
- [ ] Check Laravel version: `php artisan --version`
- [ ] Test main application functionality
- [ ] Verify Filament admin panel is accessible at `/admin`
- [ ] Check that queue workers are processing jobs
- [ ] Verify scheduled tasks are running
- [ ] Test database connections
- [ ] Review application logs for any errors

## Known Issues

### QR Code Generation
QR code generation functionality has been temporarily disabled due to package incompatibility. To restore this functionality:

**Option 1**: Implement using bacon/bacon-qr-code directly
```php
use BaconQrCode\Renderer\ImageRenderer;
use BaconQrCode\Renderer\Image\SvgImageBackEnd;
use BaconQrCode\Renderer\RendererStyle\RendererStyle;
use BaconQrCode\Writer;

$renderer = new ImageRenderer(
    new RendererStyle(400),
    new SvgImageBackEnd()
);
$writer = new Writer($renderer);
$qrCode = $writer->writeString('Your content here');
```

**Option 2**: Use endroid/qr-code package
```bash
composer require endroid/qr-code
```

## Path-Agnostic Installation

### For New Installations
```bash
# Install to custom directory
./install-fspbx.sh /var/www/pbx
```

### For Existing Installations
If you need to move your installation:
```bash
# Stop services
sudo supervisorctl stop all

# Move installation
sudo mv /var/www/fspbx /var/www/pbx

# Update cron jobs
cd /var/www/pbx
export INSTALL_DIR=/var/www/pbx
sudo bash install/install_cron_jobs.sh

# Update supervisor configs
sudo bash -c "sed 's|__INSTALL_DIR__|/var/www/pbx|g' install/horizon.conf.template > /etc/supervisor/conf.d/horizon.conf"
sudo bash -c "sed 's|__INSTALL_DIR__|/var/www/pbx|g' install/fs-cdr-service.conf.template > /etc/supervisor/conf.d/fs-cdr-service.conf"
sudo supervisorctl reread
sudo supervisorctl update

# Restart services
sudo supervisorctl start all
```

## Troubleshooting

### Composer Dependency Issues
If you encounter composer dependency conflicts:
```bash
composer update --with-all-dependencies
```

### Cache Issues
Clear all caches:
```bash
php artisan optimize:clear
```

### Permission Issues
Ensure proper ownership:
```bash
sudo chown -R www-data:www-data storage bootstrap/cache
sudo chmod -R 775 storage bootstrap/cache
```

### Horizon Not Starting
```bash
# Clear Horizon cache
php artisan horizon:clear

# Restart Horizon
sudo supervisorctl restart horizon:*
```

## Performance Improvements

Laravel 12 brings several performance improvements:
- Faster routing
- Improved query builder performance
- Better memory management
- Optimized asset compilation

## Security Enhancements

- Updated dependencies address known vulnerabilities
- PHP 8.2+ includes security improvements
- Laravel 12 security patches
- Updated Sanctum authentication

## Resources

- [Laravel 12 Documentation](https://laravel.com/docs/12.x)
- [Laravel 12 Upgrade Guide](https://laravel.com/docs/12.x/upgrade)
- [Filament Documentation](https://filamentphp.com/docs)
- [Installation Paths Guide](install/INSTALLATION_PATHS.md)

## Support

For issues or questions:
1. Check application logs: `storage/logs/laravel.log`
2. Review this upgrade guide
3. Consult the Laravel 12 documentation
4. Contact support for assistance
