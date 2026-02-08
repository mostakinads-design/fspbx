
# FS PBX

## Overview

This project started as a fork of the FusionPBX system but has been extensively redesigned. The front end has been redeveloped using Laravel for the backend and Vue.js for the front end. This new implementation aims to enhance user experience, improve performance, and provide a more modern and maintainable codebase.

## Features

- **Laravel Backend**: Robust and scalable backend infrastructure.
- **Vue.js Front End**: Responsive and interactive user interface.
- **Integration with FusionPBX**: Integration with remaining FusionPBX features.
- **Tailwind CSS**: Modern and utility-first CSS framework for styling.
- **Modular Design**: Easy to extend and maintain.

## Video Installation tutorial in 10 minutes

[https://youtu.be/7v8sepsqnH4](https://youtu.be/go6dUce0Nis)

[![VIDEO WALKTHOUGH](https://img.youtube.com/vi/go6dUce0Nis/0.jpg)](https://www.youtube.com/watch?v=go6dUce0Nis)


## Screenshots
<img width="1780" height="940" alt="image" src="https://github.com/user-attachments/assets/55df5cfd-8884-4eab-82a5-e37ed08482c8" />


<img width="1743" height="788" alt="image" src="https://github.com/user-attachments/assets/58fccf2e-fa37-48cd-8fba-95638cdce509" />

<img width="1799" height="949" alt="image" src="https://github.com/user-attachments/assets/6b386d8a-8d03-49ea-bb13-13aa7ed70bba" />

<img width="1803" height="948" alt="image" src="https://github.com/user-attachments/assets/0033182b-cefe-4ed3-8202-78f1d93c16f6" />

<img width="1754" height="813" alt="image" src="https://github.com/user-attachments/assets/be79b843-44c6-4e8f-bacb-1457c103d24d" />

<img width="1793" height="947" alt="image" src="https://github.com/user-attachments/assets/a354035a-6a90-4c6d-a32a-bc0ff301f416" />


![Image](https://github.com/user-attachments/assets/507dfa97-0264-480d-a186-767f1bcf7da8)

![Image](https://github.com/user-attachments/assets/c1dcb6da-1a17-44b5-8bc3-cde49faeca07)

<img width="2417" alt="image" src="https://github.com/user-attachments/assets/5c885878-053c-4e4d-800f-7ad4d919894d">


## Prerequisites

Before you begin, ensure you have met the following requirements:

- Debian 12 or 13
- 4GB of RAM (for production, more RAM is recommended)
- 30 GB Hard drive ( for production, an NVME hard drive with more space is recommended)

## Installation

1. **Download and run the installation script**

   ```bash
    wget -O- https://raw.githubusercontent.com/nemerald-voip/fspbx/main/install/install-fspbx.sh | bash
   ```

2. **Configure a custom domain and Let's Encrypt certificate (OPTIONAL)**

    Follow the steps in this article to configure your custom domain.
   
    [How to Secure FS PBX with a Let’s Encrypt SSL Certificate](https://github.com/nemerald-voip/fspbx/wiki/How-to-Secure-FS-PBX-with-a-Let%E2%80%99s-Encrypt-SSL-Certificate)

3. **Troubleshooting Error 419 (Page Expired)**

    Read [this article](https://github.com/nemerald-voip/fspbx/wiki/Troubleshooting-Error-419-(Page-Expired)) to learn how CSRF tokens protect your app and how to configure your server to prevent 419 responses.
   
### Usage
After completing the installation steps, you can access the application at your domain.


## How to update
Pull new updates and install them by running these commands from your installation directory:

   ```bash
   cd /path/to/your/fspbx  # Replace with your actual installation path (e.g., /var/www/fspbx or /var/www/pbx)
   git pull
   php artisan app:update
   ```
Check if there are any pending database updates.

   ```bash
   php artisan migrate:status
   ```
If you find any updates pending, run this command to install them. 
   ```bash
   php artisan migrate
   ```

## Filament Admin Panel

FS PBX now includes a modern admin panel built with [Filament](https://filamentphp.com/) for streamlined system management.

### Accessing the Admin Panel

After installation, the Filament admin panel is available at:
```
https://your-domain.com/admin
```

### Creating an Admin User

To create an admin user for the Filament panel:

```bash
cd /path/to/your/fspbx  # Replace with your actual installation path
php artisan make:filament-user
```

Follow the prompts to enter:
- Name
- Email address  
- Password

### Features

The Filament admin panel provides:
- Modern, intuitive interface
- User management
- System configuration
- Real-time dashboard
- Easy extensibility for custom resources

### Laravel 12 Upgrade

FS PBX has been upgraded to **Laravel 12** for improved performance, security, and modern PHP 8.2+ features. The upgrade includes:
- PHP 8.2+ requirement
- Updated dependencies for Laravel 12 compatibility
- Path-agnostic installation (works from any directory)
- Enhanced security and performance

For more details on the Laravel 12 upgrade, see the [upgrade notes](UPGRADE.md).

## Premium Modules
Unlock the full potential of your PBX with our two exciting premium modules designed to take your system to the next level:

**Contact Center Module**: Elevate your call management with an elegant live dashboard and a powerful management portal, ensuring every queue is optimized and easy to control.

**STIR/SHAKEN Module**: Ensure call authenticity with the STIR/SHAKEN module, giving you the power to sign all your calls with Attestation A using your very own certificate.

Experience enhanced functionality and seamless control like never before!

## Contact
For any questions or feedback, please contact us for support.


