#!/bin/bash
set -euo pipefail

# Load environment variables 
set -a
source /vagrant/.env
set +a


# Install dependencies
sudo apt-get update
sudo apt-get install -y mysql-server mysql-client apache2 libapache2-mod-php$PHP_VERSION \
                   php$PHP_VERSION php$PHP_VERSION-mysql php$PHP_VERSION-curl \
                   php$PHP_VERSION-gd php$PHP_VERSION-mbstring php$PHP_VERSION-xml \
                   php$PHP_VERSION-xmlrpc php$PHP_VERSION-soap php$PHP_VERSION-intl \
                   php$PHP_VERSION-zip