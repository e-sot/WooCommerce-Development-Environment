#!/bin/bash
set -euo pipefail

# Load logging functions
source /vagrant/provision/00-logging.sh

# Check if wp is present in the current directory
if [ -f "wp" ]; then
  echo "WP-CLI found in the current directory"
else
  echo "WP-CLI not found in the current directory"
fi

# Install wp if not found
if [ ! -f "wp" ]; then
  curl -O https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar
  chmod +x wp-cli.phar
  sudo mv wp-cli.phar /usr/local/bin/wp
  echo "WP-CLI installed successfully"
fi

# Check if wp is present in /usr/local/bin/
if [ -f "/usr/local/bin/wp" ]; then
  echo "WP-CLI found in /usr/local/bin/"
  WP_CLI_PATH="/usr/local/bin/wp"
else
  echo "WP-CLI not found in /usr/local/bin/"
fi

# Search for wp in other directories if not found in /usr/local/bin/
if [ -z "$WP_CLI_PATH" ]; then
  WP_CLI_PATH=$(find / -name wp 2>/dev/null | head -n 1)
  if [ -n "$WP_CLI_PATH" ]; then
    echo "WP-CLI found at $WP_CLI_PATH"
  else
    echo "WP-CLI not found anywhere"
    exit 1
  fi
fi

# Check if WP_CLI_PATH exists in .env file
if grep -q "WP_CLI_PATH=" /vagrant/.env; then
  # Update WP_CLI_PATH value in .env file
  sed -i "s|WP_CLI_PATH=.*|WP_CLI_PATH=\"$WP_CLI_PATH\"|" /vagrant/.env
  echo "WP_CLI_PATH updated in .env file"
else
  # Add WP_CLI_PATH to .env file
  echo "WP_CLI_PATH=\"$WP_CLI_PATH\"" >> /vagrant/.env
  echo "WP_CLI_PATH added to .env file"
fi

# Load environment variables 
set -a
source /vagrant/.env
set +a

# Check if WordPress is already installed
if ! $WP_CLI_PATH core is-installed; then
  # Download and install WordPress
  log_info "Installing WordPress..."
  $WP_CLI_PATH core download --version=$WORDPRESS_VERSION --allow-root
  $WP_CLI_PATH config create --dbname="$WORDPRESS_DB_NAME" --dbuser="$WORDPRESS_DB_USER" --dbpass="$WORDPRESS_DB_PASSWORD" --dbhost="$WORDPRESS_DB_HOST" --allow-root
  $WP_CLI_PATH core install --url="$WORDPRESS_SITE_URL" --title="$WORDPRESS_SITE_TITLE" \
                  --admin_user="$WORDPRESS_ADMIN_USER" --admin_password="$WORDPRESS_ADMIN_PASSWORD" \
                  --admin_email="$WORDPRESS_ADMIN_EMAIL" --skip-email --allow-root
else
  log_info "WordPress is already installed. Skipping WordPress installation."
fi

# Check if the specified theme is already installed
if ! $WP_CLI_PATH theme is-installed "$WORDPRESS_ACTIVE_THEME"; then
  # Install and activate theme
  if [ -n "$WORDPRESS_ACTIVE_THEME" ]; then
    log_info "Installing $WORDPRESS_ACTIVE_THEME theme..."
    $WP_CLI_PATH theme install "$WORDPRESS_ACTIVE_THEME" --allow-root

    log_info "Activating $WORDPRESS_ACTIVE_THEME theme..."
    $WP_CLI_PATH theme activate "$WORDPRESS_ACTIVE_THEME" --allow-root
  fi
else
  log_info "The $WORDPRESS_ACTIVE_THEME theme is already installed. Skipping theme installation."
fi