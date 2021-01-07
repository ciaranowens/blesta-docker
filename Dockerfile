FROM php:7.4-fpm-buster

RUN set -eux; \
  apt-get update && apt-get dist-upgrade -y

RUN set -eux; \
	apt-get install -y --no-install-recommends \
		libc-client-dev \
		libkrb5-dev \
    libcurl4-openssl-dev \
    libgmp-dev \
    libonig-dev \
    zlib1g \
    libfreetype6-dev \
    libjpeg62-turbo-dev \
    libpng-dev \
	; \
	rm -rf /var/lib/apt/lists/*

RUN set -eux; \
	PHP_OPENSSL=yes docker-php-ext-configure imap --with-kerberos --with-imap-ssl; \
	docker-php-ext-install imap

# PECL installs
RUN set -eux; \
  pecl install mailparse

# Enabling any extensions like from above (along with other Dockerizing of PHP stuff)
RUN set -eux; \
  docker-php-ext-enable mailparse

RUN set -eux; \
  docker-php-ext-install pdo pdo_mysql curl gmp mbstring

RUN set -eux; \
  docker-php-ext-install gd 

# IonCube Install
RUN cd /tmp \
    && curl -s -o ioncube.tar.gz http://downloads3.ioncube.com/loader_downloads/ioncube_loaders_lin_x86-64.tar.gz \
    && tar -zxf ioncube.tar.gz \
    && mv ioncube/ioncube_loader_lin_7.4.so /usr/local/lib/php/extensions/no-debug-non-zts-20190902/ \
    && rm -Rf ioncube.tar.gz ioncube \
    && echo "zend_extension=ioncube_loader_lin_7.4.so" > /usr/local/etc/php/conf.d/00_docker-php-ext-ioncube.ini

# Blesta File Install
RUN cd /tmp \
    && curl -s -O https://account.blesta.com/client/plugin/download_manager/client_main/download/169/blesta-4.12.3.zip \
    && unzip -qq blesta-4.12.3.zip \
    && rm blesta-4.12.3.zip \
    && mv uploads /var/www \
    && mv blesta/* blesta/.h* /var/www/html

RUN chown -R www-data: /var/www/html

EXPOSE 80 443