#!/bin/bash
set -euo pipefail

# Load environment variables 
set -a
source /vagrant/.env
set +a


# Load logging functions
source /vagrant/provision/00-logging.sh

# Install and activate WooCommerce 
log_info "Installation et activation de WooCommerce..."
wp plugin install woocommerce --activate --force --allow-root

# Configure WooCommerce
log_info "Configuration de WooCommerce..."
wp wc tool run install_pages --user="$WORDPRESS_ADMIN_USER" --allow-root
wp option set woocommerce_store_address "$WOOCOMMERCE_STORE_ADDRESS" --allow-root  
wp option set woocommerce_store_address_2 "$WOOCOMMERCE_STORE_ADDRESS_2" --allow-root
wp option set woocommerce_store_city "$WOOCOMMERCE_STORE_CITY" --allow-root
wp option set woocommerce_default_country "$WOOCOMMERCE_DEFAULT_COUNTRY" --allow-root  
wp option set woocommerce_store_postcode "$WOOCOMMERCE_STORE_POSTCODE" --allow-root

