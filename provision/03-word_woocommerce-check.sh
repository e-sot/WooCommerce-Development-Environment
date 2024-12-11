#!/bin/bash
set -euo pipefail

# Load logging functions
source /vagrant/provision/00-logging.sh

# Configure Apache to serve WordPress from /var/www/html/wordpress
if ! grep -q "/var/www/html/wordpress" /etc/apache2/sites-available/000-default.conf; then
    log_info "Configuring Apache to serve WordPress from /var/www/html/wordpress..."
    sudo sed -i 's|/var/www/html|/var/www/html/wordpress|' /etc/apache2/sites-available/000-default.conf
    sudo service apache2 restart
fi

# Check if WordPress is installed in the expected directory
if [ ! -d "/var/www/html/wordpress" ]; then
    log_error "Error: WordPress is not installed in /var/www/html/wordpress"
    exit 1
fi

# Check if Apache is configured correctly for WordPress
if ! grep -q "/var/www/html/wordpress" /etc/apache2/sites-available/000-default.conf; then
    log_error "Error: Apache virtual host is not configured correctly for WordPress"
    exit 1
fi

# Check if mod_rewrite is enabled
if ! sudo apache2ctl -M | grep -q "rewrite_module"; then
    log_info "Enabling mod_rewrite..."
    sudo a2enmod rewrite
    sudo service apache2 restart
fi

# Check file and directory permissions
if [ "$(stat -c '%U' /var/www/html/wordpress)" != "www-data" ] || [ "$(stat -c '%G' /var/www/html/wordpress)" != "www-data" ]; then
    log_info "Updating WordPress directory ownership..."
    sudo chown -R www-data:www-data /var/www/html/wordpress
fi

if [ "$(stat -c '%a' /var/www/html/wordpress)" -lt 755 ]; then
    log_info "Updating WordPress directory permissions..."
    sudo chmod -R 755 /var/www/html/wordpress
fi

# Check WordPress database connection
if ! wp db check --allow-root; then
    log_error "Error: WordPress database connection failed"
    exit 1
fi

# Check Apache and WordPress error logs
if grep -qi "error" /var/log/apache2/error.log; then
    log_error "Error: Apache error log contains errors"
    exit 1
fi

if grep -qi "error" /var/www/html/wordpress/wp-content/debug.log; then
    log_error "Error: WordPress debug log contains errors"
    exit 1
fi

# Check WordPress wp-config.php file
if ! grep -q "DB_NAME" /var/www/html/wordpress/wp-config.php || ! grep -q "DB_USER" /var/www/html/wordpress/wp-config.php || ! grep -q "DB_PASSWORD" /var/www/html/wordpress/wp-config.php; then
    log_error "Error: WordPress wp-config.php file is missing or has incorrect database configuration"
    exit 1
fi

# Check WordPress URL
WORDPRESS_URL=$(wp option get siteurl --allow-root)
if [ "$WORDPRESS_URL" != "http://localhost:8181/wordpress" ]; then
    log_info "Updating WordPress URL..."
    wp option update siteurl "http://localhost:8181/wordpress" --allow-root
    wp option update home "http://localhost:8181/wordpress" --allow-root
fi

# Check file and directory permissions
if [ "$(stat -c '%U' /var/www/html/wordpress)" != "www-data" ] || [ "$(stat -c '%G' /var/www/html/wordpress)" != "www-data" ]; then
    log_info "Updating WordPress directory ownership..."
    chown -R www-data:www-data /var/www/html/wordpress
fi

if [ "$(stat -c '%a' /var/www/html/wordpress)" -lt 755 ]; then
    log_info "Updating WordPress directory permissions..."
    chmod -R 755 /var/www/html/wordpress
fi

