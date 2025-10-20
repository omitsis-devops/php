ARG PHP_VERSION
#FROM public.ecr.aws/docker/library/php:${PHP_VERSION:+${PHP_VERSION}-}fpm-alpine
FROM php:${PHP_VERSION:+${PHP_VERSION}-}fpm-alpine

COPY ./php-fpm-healthcheck.sh /usr/bin/php-fpm-healthcheck
RUN chmod +x /usr/bin/php-fpm-healthcheck

RUN apk add --no-cache fcgi bash linux-headers tzdata musl-locales shadow git mariadb-client unzip zip freetype-dev libpng-dev jpeg-dev libjpeg-turbo-dev libwebp libwebp-tools libavif-dev imagemagick && \
    echo "pm.status_path = /status" >> /usr/local/etc/php-fpm.d/zzz-docker.conf && \
    cp /usr/share/zoneinfo/Europe/Brussels /etc/localtime && \
    echo "Europe/Brussels" > /etc/timezone && \
    apk del tzdata

ENV LANG="en_US.UTF-8" LANGUAGE="en_US:en" LC_ALL="en_US.UTF-8" XDEBUG_MODE="off"

ARG UNAME=www-data UGROUP=www-data UID=1000 GID=1000
RUN usermod --uid $UID $UNAME && groupmod --gid $GID $UGROUP

ADD https://github.com/mlocati/docker-php-extension-installer/releases/latest/download/install-php-extensions /usr/local/bin/
RUN chmod +x /usr/local/bin/install-php-extensions && \
    install-php-extensions bcmath exif mysqli pdo_mysql zip gd xdebug opcache

RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer

RUN mkdir -p /var/www/html && chown -R $UID:$GID /var/www/html
WORKDIR /var/www/html

COPY development/xdebug.ini /usr/local/etc/php/conf.d/docker-php-ext-xdebug.ini
RUN chmod 644 /usr/local/etc/php/conf.d/docker-php-ext-xdebug.ini && \
    chmod -R 755 /usr/local/lib/php/extensions/ && \
    rm -f $PHP_INI_DIR/conf.d/docker-fpm.ini

HEALTHCHECK --interval=30s --timeout=1s CMD php-fpm-healthcheck || exit 1

USER www-data
