#!/bin/bash
set -euo pipefail

# Load logging functions
source /vagrant/provision/00-logging.sh

# Load environment variables
set -a
source /vagrant/.env
set +a

# Generate API keys
log_info "Generating API keys..."
WOOCOMMERCE_CONSUMER_KEY=$(openssl rand -hex 32)
WOOCOMMERCE_CONSUMER_SECRET=$(openssl rand -hex 64)

# Check if woocommerce_consumer_key option exists
if wp option get woocommerce_consumer_key >/dev/null 2>&1; then
    # Update woocommerce_consumer_key option
    wp option update woocommerce_consumer_key $WOOCOMMERCE_CONSUMER_KEY --allow-root
else
    # Add woocommerce_consumer_key option
    wp option add woocommerce_consumer_key $WOOCOMMERCE_CONSUMER_KEY --allow-root
fi

# Check if woocommerce_consumer_secret option exists
if wp option get woocommerce_consumer_secret >/dev/null 2>&1; then
    # Update woocommerce_consumer_secret option
    wp option update woocommerce_consumer_secret $WOOCOMMERCE_CONSUMER_SECRET --allow-root
else
    # Add woocommerce_consumer_secret option
    wp option add woocommerce_consumer_secret $WOOCOMMERCE_CONSUMER_SECRET --allow-root
fi

if [ -n "$WOOCOMMERCE_CONSUMER_KEY" ] && [ -n "$WOOCOMMERCE_CONSUMER_SECRET" ]; then
    log_info "API keys generated successfully"
    wp eval 'WC_Install::install();' --allow-root

    # Create new WooCommerce API keys using direct database insertion
    USER_ID=$(wp user get $(wp user list --field=user_login --format=csv --allow-root | grep -w "$WORDPRESS_ADMIN_USER") --field=ID --allow-root)
    if [ -n "$USER_ID" ]; then
        wp db query "INSERT INTO \`$(wp db prefix --allow-root)woocommerce_api_keys\` (\`user_id\`, \`description\`, \`permissions\`, \`consumer_key\`, \`consumer_secret\`, \`truncated_key\`) VALUES ('$USER_ID', 'Admin API Key', 'read_write', '$WOOCOMMERCE_CONSUMER_KEY', '$WOOCOMMERCE_CONSUMER_SECRET', SUBSTR('$WOOCOMMERCE_CONSUMER_KEY', -7));" --allow-root
        log_info "WooCommerce API keys created successfully"
    else
        log_error "Error: Unable to find the admin user ID"
        exit 1
    fi
    
    # Install and activate Permalink Manager Lite plugin
    wp plugin install permalink-manager --activate --allow-root

    # Check if WooCommerce plugin is installed and active
    if ! wp plugin is-installed woocommerce --allow-root || ! wp plugin is-active woocommerce --allow-root; then
        log_error "Error: WooCommerce plugin is not installed or active."
        exit 1
    fi
    
    # Check if WooCommerce REST API is enabled
    if ! wp option get woocommerce_api_enabled --allow-root | grep -q "yes"; then
        log_info "WooCommerce REST API is not enabled. Enabling it now..."
        wp option update woocommerce_api_enabled yes --allow-root
    fi

    # Get REST API URL 
    REST_API_URL=$(wp eval "echo get_rest_url();" --allow-root)
    echo "REST API URL: $REST_API_URL"
    
    # Test if REST API is responding
    API_RESPONSE_CODE=$(curl -i -s -o /dev/null -w "%{http_code}" ${REST_API_URL}wc/v3/system_status)
    if [[ "$API_RESPONSE_CODE" == "200" ]]; then 
        log_info "REST API is responding"
    else
        log_error "REST API is not responding. Response code: $API_RESPONSE_CODE"
        exit 1
    fi

    # Test if API keys in database match generated keys
    DB_CONSUMER_KEY=$(wp eval "echo get_option('woocommerce_consumer_key');" --allow-root)
    DB_CONSUMER_SECRET=$(wp eval "echo get_option('woocommerce_consumer_secret');" --allow-root)
    
    if [[ "$DB_CONSUMER_KEY" == "$WOOCOMMERCE_CONSUMER_KEY" ]] && [[ "$DB_CONSUMER_SECRET" == "$WOOCOMMERCE_CONSUMER_SECRET" ]]; then
        log_info "API keys in database match generated keys"

        # Test API credentials
        SYSTEM_STATUS=$(curl -s -u "$WOOCOMMERCE_CONSUMER_KEY:$WOOCOMMERCE_CONSUMER_SECRET" ${REST_API_URL}wc/v3/system_status)
        if [[ $SYSTEM_STATUS == *"environment"* ]]; then
            log_info "API credentials are working"
        else
            log_error "Error: API credentials not working"
            exit 1 
        fi  
    else
        log_error "Error: API keys in database do not match generated keys"
        exit 1
    fi

    # Clear WordPress cache
    wp plugin install wp-cli-clear-cache --activate --allow-root
    wp clear-cache --allow-root
    
else
    log_error "Error generating API keys"
    exit 1
fi