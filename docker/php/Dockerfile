FROM php:8.2-fpm

# Fix debconf warnings upon build
ARG DEBIAN_FRONTEND=noninteractive

ARG DOCKER_GROUP_ID
ARG DOCKER_USER_ID

USER root

RUN usermod -u ${DOCKER_USER_ID} -d /var/www/html www-data && \
    groupmod -g ${DOCKER_GROUP_ID} www-data

# Fix user permissions
RUN mkdir -p /var/www/html

RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer
RUN chown www-data:www-data /usr/local/bin && \
    chmod 755 /usr/local/bin

ADD https://github.com/mlocati/docker-php-extension-installer/releases/latest/download/install-php-extensions /usr/local/bin/

RUN apt update && apt install -y \
        libfreetype6-dev \
        libjpeg62-turbo-dev \
        libpng-dev \
        zip \
        unzip \
        git \
    && docker-php-ext-install mysqli pdo pdo_mysql exif

RUN pecl install -o -f redis \
    && rm -rf /tmp/pear \
    && docker-php-ext-enable redis

RUN chmod +x /usr/local/bin/install-php-extensions && \
    install-php-extensions \
        mysql pgsql pdo pdo_mysql redis sqlite3 xdebug \
        bcmath bz2 dba \
        enchant gd gmp igbinary imagick imap \
        intl ldap mongodb msgpack soap ssh2 \
        sybase tideways tidy xmlrpc xsl \
    && apt-get clean; rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* /usr/share/doc/*

USER www-data

COPY composer.json composer.json

RUN composer i \
   --no-interaction \
   --no-plugins \
   --no-scripts \
   --prefer-dist

COPY --chown=www-data:www-data . .

RUN composer dump-autoload

RUN php artisan key:generate
RUN php artisan storage:link

CMD [ "php-fpm" ]
