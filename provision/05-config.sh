#!/bin/bash
set -euo pipefail

# Load environment variables 
set -a
source /vagrant/.env
set +a


# Load logging functions
source /vagrant/provision/00-logging.sh

# Update security keys
log_info "Updating security keys..."
wp config shuffle-salts --allow-root

# Disable WP_DEBUG in wp-config.php
log_info "Disabling debug mode..."
wp config set WP_DEBUG false --raw --allow-root
