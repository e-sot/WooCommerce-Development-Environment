#!/bin/bash
set -euo pipefail

# Load logging functions
source /vagrant/provision/00-logging.sh

# Backup the database
log_info "Backing up the database..."
wp db export /vagrant/wordpress_db_backup.sql --allow-root
