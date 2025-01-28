# Omitsis PHP Docker Image

This repository contains a custom PHP Docker image based on PHP-FPM with an Alpine Linux distribution. The image is tailored to enhance PHP development by including essential tools and extensions.

It uses the official php-fpm image, and adds some extras based on that image.

## Features

- **PHP Version**: Dynamically specified version of PHP-FPM.
- **Alpine Base**: Lightweight and secure Alpine Linux.
- **Default Extensions**:
  - bcmath
  - exif
  - mysqli
  - pdo_mysql
  - zip
  - gd
  - xdebug
- **PHP FPM Configuration**: Adds status path for monitoring.
- **Time Zone Configuration**: Sets default timezone to Europe/Brussels.
- **Locale**: Configured to `en_US.UTF-8`.
- **Tools**: Composer for PHP dependency management.
- **Development Tools**: Includes `git`, `bash`, and a health check script.
- **Health Check**: Built-in health check for PHP-FPM service.
- **Custom User and Group**: Modifies UID/GID to support specific user/group.

## Usage

1. **Build the Image**:
   ```sh
   docker build --build-arg PHP_VERSION=<desired_version> -t custom-php-image .
   ```

2. **Run the Container**:
   ```sh
   docker run -d custom-php-image
   ```

3. **Check Health**:
   - The health check script verifies PHP-FPM status at `/status`.

## File Structure

- **Dockerfile**: Defines the custom PHP image setup.
- **php-fpm-healthcheck.sh**: Script for checking PHP-FPM health.
- **development/xdebug.ini**: Configuration file for Xdebug.

## Environment Variables

- **PHP_VERSION**: Specify the PHP version to use.
- **XDEBUG_MODE**: Default is off, toggle xdebug as needed.
- **LANG, LANGUAGE, LC_ALL**: Set to `en_US.UTF-8`.

## Additional Notes

- **Healthcheck**: This runs via a command script, configured for intervals of 30s.
- **User Rights**: Adjusts file permissions to ensure proper access and security.

## Contributing

Feel free to open issues or submit pull requests to contribute to this project.

---

For detailed usage and customization, refer to the Dockerfile and related script files within the repository.
