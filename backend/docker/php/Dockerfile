FROM php:8.2-fpm

RUN apt-get update && apt-get install -y \
    git \
    unzip \
    zip \
    libpng-dev \
    && docker-php-ext-install pdo pdo_mysql

COPY uploads.ini /usr/local/etc/php/conf.d/uploads.ini

WORKDIR /var/www
