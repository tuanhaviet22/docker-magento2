SHELL := /bin/bash

define add_uid =
	if ! grep -xq "UID=.*" $1; then \
	  echo "UID=$$(id -u)" | tee --append $1; \
	fi
endef

define add_host =
	if ! grep -xq "$1	$2" /etc/hosts; then \
	  echo -ne "\n$1	$2" | tee --append /etc/hosts; \
	fi
endef

dev_ssh := 
dev_db := 

DOCKER_COMPOSE_EXISTS := $(shell command -v docker-compose 2> /dev/null)
ifdef DOCKER_COMPOSE_EXISTS
DOCKER_COMPOSE := docker-compose
EXEC := $(DOCKER_COMPOSE) exec
PHP=$(EXEC) php
endif

CONSOLE=$(EXEC) php bin/magento

.PHONY=setup host clean upgrade

upgrade:
	$(CONSOLE) setup:upgrade

static_deploy:
	rm -rdf var/view_preprocessed/
	$(CONSOLE) setup:static-content:deploy -f

setup: env up composer_install host magento_install disable_2fa

composer_install:
	$(PHP) composer install

npm_install:
	$(PHP) npm install

grunt_exec:
	$(PHP) grunt exec

grunt_watch:
	$(PHP) grunt watch

env:
	$(call add_uid, .env)

up:
	$(DOCKER_COMPOSE) up -d

config:
	$(CONSOLE) config:set catalog/search/elasticsearch7_server_hostname es
	$(CONSOLE) config:set web/unsecure/base_url http://magento.local/


magento_init:
	composer create-project --repository-url=https://repo.magento.com/ magento/project-community-edition .
	
magento_install:
	$(CONSOLE) setup:install \
--base-url=http://magento.local/ \
--elasticsearch-host=es \
--db-host=sql \
--db-name=magento \
--db-user=magento \
--db-password=magento \
--admin-firstname=admin \
--admin-lastname=admin \
--admin-email='admin@admin.com' \
--admin-user=admin \
--admin-password=admin123 \
--language=fr_FR \
--currency=EUR \
--timezone=Europe/Paris \
--use-rewrites=1

disable_2fa:
	$(CONSOLE) module:disable Magento_TwoFactorAuth
	$(CONSOLE) cache:flush

host:
	$(call add_host,127.0.0.1,magento.local)

clean:
	rm -rf var/cache/ generated/ var/page_cache/ var/view_preprocessed/ pub/static/

# Tests
phpcs:
	$(PHP) composer run phpcs
