FROM php:7.4-fpm

# Install necessary libraries for Magento2
RUN apt-get -y update \
    && apt-get -y install \
        libmcrypt-dev \
        libxslt-dev \
        zlib1g-dev \
        libpng-dev \
        libjpeg-dev \
        libfreetype6-dev \
        libjpeg62-turbo-dev \
        libzip-dev \
        git \
        unzip \
    && apt-get autoremove -y \
    && apt-get autoclean -y \
    && rm -rf /var/lib/apt/lists/*

RUN docker-php-ext-configure gd --with-freetype=/usr/include/ --with-jpeg=/usr/include/ \
    && docker-php-ext-install -j$(nproc) iconv pdo_mysql xsl intl zip bcmath gd soap gettext exif sockets

# Install composer
RUN php -r "copy('https://getcomposer.org/installer', '/tmp/composer-setup.php');" \
 && php /tmp/composer-setup.php --install-dir=/usr/local/bin --filename=composer \
 && php -r "unlink('/tmp/composer-setup.php');"

# Set memory_limit
RUN echo "php_admin_value[memory_limit] = 2048M" >> /usr/local/etc/php-fpm.d/www.conf \
&& echo "memory_limit = 2048M" >> /usr/local/etc/php/conf.d/memory_limit.ini

# Set execution timeout
RUN echo "request_terminate_timeout = 0" >> /usr/local/etc/php-fpm.d/www.conf \
&& echo "max_execution_time = 0" >> /usr/local/etc/php/conf.d/max_execution_time.ini


# Install Node.js
RUN curl -fsSL https://deb.nodesource.com/setup_12.x | bash - \
&& apt-get install -y nodejs

# JS dep
RUN npm install -g grunt-cli

ARG UID
ARG USER=sutunam

# Create non-root user
RUN useradd -m -U ${USER} -u ${UID} -s /bin/bash -o
## Change www-data user to ${USER}
RUN sed -i -e "s/www-data/${USER}/" /usr/local/etc/php-fpm.d/www.conf

WORKDIR /var/www/magento

USER ${USER}

RUN mkdir -p /home/${USER}/.composer /home/${USER}/.ssh

USER root
RUN chown -R ${USER}:${USER} /home/${USER}/.ssh/

USER ${USER}
