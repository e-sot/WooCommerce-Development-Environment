# WooCommerce Development Environment

A streamlined Vagrant-based development environment for WordPress and WooCommerce with automated provisioning and configuration.

## Overview

This project provides a complete local development environment for WooCommerce stores using Vagrant and VirtualBox. It features automated installation and configuration of WordPress, WooCommerce, and all necessary dependencies.

## Features

- **Environment Setup**:
  - Ubuntu 20.04 LTS (Focal Fossa) base box
  - Apache2 web server
  - PHP 7.4
  - MySQL Server
  - WordPress (latest version)
  - WooCommerce (latest version)

- **Automated Configuration**:
  - WordPress core installation and configuration
  - WooCommerce setup with store details
  - Database creation and security configuration
  - API key generation for WooCommerce REST API
  - Proper file permissions and ownership
  - Apache virtual host configuration

- **Development Tools**:
  - WP-CLI integration
  - Environment variable management
  - Automated backup functionality
  - Security key management
  - Debug mode control

## Requirements

- Vagrant
- VirtualBox
- Required Vagrant plugins:
  - `vagrant-env`
  - `vagrant-vbguest`
  - `vagrant-hostmanager`

## Quick Start

1. Clone the repository.
2. Copy `.env.example` to `.env` and configure your settings.
3. Run `vagrant up`.
4. Access your store at `http://localhost:8181`.

## Environment Configuration

Configure your development environment by editing the `.env` file with your preferred settings:

```env
WORDPRESS_SITE_URL=http://localhost:8181
WORDPRESS_SITE_TITLE="My WooCommerce Store"
WORDPRESS_ADMIN_USER=admin
WORDPRESS_ADMIN_PASSWORD=password
WORDPRESS_ADMIN_EMAIL=admin@example.com
```

## Project Structure

```text
.
├── provision/           # Provisioning scripts
├── .env                # Environment configuration
├── Vagrantfile         # Vagrant configuration
├── config.yml          # VM settings
```
