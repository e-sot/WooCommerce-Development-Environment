#!/bin/bash
set -euo pipefail

# Load logging functions
source /vagrant/provision/00-logging.sh

# Load environment variables 
set -a
source /vagrant/.env
set +a

# Install MySQL
log_info "Installing MySQL..."
sudo apt-get install -y mysql-server

# Secure MySQL installation
log_info "Securing MySQL installation..."
sudo mysql -p"$WORDPRESS_DB_ROOT_PASSWORD" <<EOF
ALTER USER 'root'@'localhost' IDENTIFIED WITH mysql_native_password BY '$WORDPRESS_DB_ROOT_PASSWORD';
DELETE FROM mysql.user WHERE User='';
DELETE FROM mysql.user WHERE User='root' AND Host NOT IN ('localhost', '127.0.0.1', '::1');
DROP DATABASE IF EXISTS test;
DELETE FROM mysql.db WHERE Db='test' OR Db='test\\_%';
FLUSH PRIVILEGES;
EOF

# Create WordPress database and user
log_info "Creating WordPress database and user..."
sudo mysql -u root -p"$WORDPRESS_DB_ROOT_PASSWORD" <<EOF
CREATE DATABASE IF NOT EXISTS $WORDPRESS_DB_NAME;
CREATE USER IF NOT EXISTS '$WORDPRESS_DB_USER'@'localhost' IDENTIFIED BY '$WORDPRESS_DB_PASSWORD';
GRANT ALL PRIVILEGES ON $WORDPRESS_DB_NAME.* TO '$WORDPRESS_DB_USER'@'localhost';
FLUSH PRIVILEGES;
EOF

# Verify MySQL is running
log_info "Verifying MySQL is running..."
if ! systemctl is-active --quiet mysql; then
  log_error "MySQL failed to start. Please check MySQL configuration."
  exit 1
fi

log_info "MySQL installation completed successfully."