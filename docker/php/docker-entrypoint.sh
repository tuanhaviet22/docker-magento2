#!/bin/bash
# From https://github.com/meanbee/docker-magento2/blob/1c1dcaec37e9efe3ec2009ebf369037e37fbf9bc/7.4-fpm/docker-entrypoint.sh

[ "$DEBUG" = "true" ] && set -x

echo "$UPDATE_UID_GID"

# Ensure our Magento directory exists
mkdir -p $MAGENTO_ROOT

# Substitute in php.ini values
[ ! -z "${PHP_MEMORY_LIMIT}" ] && sed -i "s/!PHP_MEMORY_LIMIT!/${PHP_MEMORY_LIMIT}/" /usr/local/etc/php/conf.d/zz-magento.ini
[ ! -z "${UPLOAD_MAX_FILESIZE}" ] && sed -i "s/!UPLOAD_MAX_FILESIZE!/${UPLOAD_MAX_FILESIZE}/" /usr/local/etc/php/conf.d/zz-magento.ini

[ "$PHP_ENABLE_XDEBUG" = "true" ] && \
    docker-php-ext-enable xdebug && \
    echo "Xdebug is enabled"


# Configure PHP-FPM
[ ! -z "${MAGENTO_RUN_MODE}" ] && sed -i "s/!MAGENTO_RUN_MODE!/${MAGENTO_RUN_MODE}/" /usr/local/etc/php-fpm.conf


exec "$@"
