.DEFAULT_GOAL := help
SHELL := /bin/bash

DEV_DB := 
DEV_SSH := 
PROD_DB :=
PROD_SSH :=

WARDEN_EXISTS := $(shell command -v warden 2> /dev/null)
ifdef WARDEN_EXISTS
	WARDEN := warden
	DOCKER_COMPOSE := warden env
	EXEC := $(DOCKER_COMPOSE) exec
	PHP=$(EXEC) php-fpm
	NODE=$(EXEC) php-fpm
endif

# Common operations
up: ## Create and start docker containers
	$(DOCKER_COMPOSE) up -d

start: ## Start environment
	$(DOCKER_COMPOSE) start

stop: ## Stop the running environment
	$(DOCKER_COMPOSE) stop

deploy: ## Deploy project
	$(PHP) composer install --no-dev
	$(PHP) bin/magento setup:upgrade
	$(PHP) bin/magento setup:di:compile
	$(PHP) bin/magento setup:static-content:deploy en_US -f
	$(PHP) bin/magento cache:flush

# Tests
phpcs: ## Run phpcs
	$(PHP) composer run phpcs

gitsniff: ## Run phpcs for the changed files only
	@$(PHP) chmod +x gitsniff.sh
	@$(PHP) ./gitsniff.sh

# Frontend
npm_install: ## Run npm install
	$(NODE) npm --prefix $(TAILWIND_DIR) install $(TAILWIND_DIR)

build: ## Build theme in production mode
	$(NODE) npm run build-prod --prefix $(TAILWIND_DIR)
	$(PHP) bin/magento cache:flush

watch: ## Watch your files for changes during the development
	$(NODE) npm --prefix $(TAILWIND_DIR) run watch

disable_2fa: ## Disable Magento_TwoFactorAuth module
	$(PHP) bin/magento module:disable Magento_TwoFactorAuth Magento_AdminAdobeImsTwoFactorAuth
	$(PHP) bin/magento cache:flush

cron_install: ## Configure and run cron jobs
	$(PHP) bin/magento cron:install || true
	$(PHP) bin/magento cron:run
	$(PHP) bin/magento cron:run

install: ## Install magento
	cp .warden/env.php.local app/etc/env.php
	$(PHP) bin/magento setup:install

install_sample_data: ## Install sample data
	$(PHP) bin/magento sampledata:deploy
	
composer_install: ## Install composer dependencies
	$(PHP) composer install

# Help
help: ## Display this menu
	@echo -e "\n\033[104m                                        \033[0m"
	@echo -e "\033[104;30;1m             Make Utility               \033[0m"
	@echo -e "\033[104m                                        \033[0m\n"
	@IFS=$$'\n'; for line in `grep -h -E '^[a-zA-Z_#-]+:?.*?## .*$$' $(MAKEFILE_LIST)`; do if [ "$${line:0:2}" = "##" ]; then \
	echo $$line | awk 'BEGIN {FS = "## "}; {printf "\n\033[33m%s\033[0m\n", $$2}'; else \
	echo $$line | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-40s\033[0m %s\n", $$1, $$2}'; fi; \
	done; unset IFS; \
	echo ""
