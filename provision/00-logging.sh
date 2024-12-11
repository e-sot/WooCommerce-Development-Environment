#!/bin/bash

# Logging functions
function log_info {
  echo "[$(date '+%Y-%m-%d %H:%M:%S')] INFO: $1" | tee -a /vagrant/provision/provision.log
}

function log_error {
  echo "[$(date '+%Y-%m-%d %H:%M:%S')] ERROR: $1" | tee -a /vagrant/provision/provision.log >&2
}
