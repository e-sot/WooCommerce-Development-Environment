#!/bin/bash
set -euo pipefail

# Load environment variables 
set -a
source /vagrant/.env
set +a

# Load variables from .env file and export them as environment variables
while IFS='=' read -r key value; do
  if [[ "$key" && "$value" ]]; then
    key=$(echo "$key" | tr '.' '_' | tr -d ' ')
    value=$(echo "$value" | sed 's/^"//' | sed 's/"$//' | sed "s/'//g")
    export "$key=$value"
  fi
done < /vagrant/.env
