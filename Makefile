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

disable_2fa: ## Disable Magento_TwoFactorAuth module
	$(PHP) bin/magento module:disable Magento_TwoFactorAuth Magento_AdminAdobeImsTwoFactorAuth
	$(PHP) bin/magento cache:flush

cron_install: ## Configure and run cron jobs
	$(PHP) bin/magento cron:install || true
	$(PHP) bin/magento cron:run
	$(PHP) bin/magento cron:run

install: ## Install magento
	docker exec -it magento2-php-fpm-1  bash ./install.sh

install_sample_data: ## Install sample data
	$(PHP) bin/magento sampledata:deploy
	$(PHP)  bin/magento module:enable \
		Magento_CatalogSampleData \
		Magento_BundleSampleData \
		Magento_GroupedProductSampleData \
		Magento_DownloadableSampleData \
		Magento_ThemeSampleData \
		Magento_ConfigurableSampleData \
		Magento_ReviewSampleData \
		Magento_OfflineShippingSampleData \
		Magento_CatalogRuleSampleData \
		Magento_TaxSampleData \
		Magento_SalesRuleSampleData \
		Magento_SwatchesSampleData \
		Magento_MsrpSampleData \
		Magento_CustomerSampleData \
		Magento_CmsSampleData \
		Magento_AdminAdobeImsTwoFactorAuth \
		Magento_SalesSampleData \
		Magento_ProductLinksSampleData \
		Magento_WidgetSampleData \
		Magento_WishlistSampleData
	$(PHP) bin/magento setup:upgrade
	$(PHP) bin/magento indexer:reindex

composer_install: ## Install composer dependencies
	$(PHP) composer install

info: ## Show information about the environment
	@echo "Admin URL: https://app.magento2.test/admin"
	@echo "Frontend URL: https://app.magento2.test"
	@echo "Username: admin"
	@echo "Password: admin123"

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
