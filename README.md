# Magento 2 Warden Environment

This repository provides a ready-to-use Magento 2 development environment using [Warden](https://warden.dev/).

## Prerequisites

- [Warden](https://warden.dev/) installed and configured
- Docker and Docker Compose
- Git

## Quick Start

```bash
# Clone this repository
git clone https://github.com/tuanhaviet22/docker-magento2.git
cd docker-magento2

# Start the environment
make up

# Install Magento
make install

# Install sample data (optional)
make install_sample_data
```

## Available Make Commands

Run `make help` to see all available commands with descriptions:

### Common Operations
- `up` - Create and start docker containers
- `start` - Start environment
- `stop` - Stop the running environment
- `deploy` - Deploy project
- `install` - Install Magento
- `install_sample_data` - Install sample data
- `composer_install` - Install composer dependencies
- `disable_2fa` - Disable Magento_TwoFactorAuth module
- `cron_install` - Configure and run cron jobs

### Cache and Indexing
- `flush` - Flush Magento cache

### Frontend
- `npm_install` - Run npm install
- `build` - Build theme in production mode
- `watch` - Watch your files for changes during the development

### Testing
- `phpcs` - Run phpcs
- `gitsniff` - Run phpcs for the changed files only

## Warden Environment

The environment includes several services:

| Service      | Description                    |
|--------------|--------------------------------|
| PHP-FPM      | PHP application server         |
| Nginx        | Web server                     |
| MariaDB      | MySQL database                 |
| Redis        | Cache and session storage      |
| Varnish      | HTTP cache                     |
| RabbitMQ     | Message broker                 |
| OpenSearch   | Search engine                  |
| MailHog      | Email testing                  |

URLs will follow the Warden convention, for example:
- Storefront: https://app.{project-name}.test/
- Admin: https://app.{project-name}.test/backend/
- RabbitMQ: https://rabbitmq.{project-name}.test/
- OpenSearch: https://opensearch.{project-name}.test/

## Additional Information

### Setup Details

This environment automatically configures:
- SSL certificates via Warden
- Redis for caching and sessions
- OpenSearch for catalog search
- RabbitMQ for message queue

### Accessing the Environment

```bash
# Access the PHP container shell
warden shell

# Run Magento CLI commands
warden env exec php-fpm bin/magento [command]

# View logs
warden env exec php-fpm tail -f var/log/system.log
```
