ARG PHP_BASEIMAGE_VERSION

FROM php:${PHP_BASEIMAGE_VERSION}-fpm-alpine as base
ARG PHP_COMPOSER_VERSION
ARG TZ
ARG USER_ID
ARG GROUP_ID
ENV TZ=${TZ}
COPY --from=mlocati/php-extension-installer /usr/bin/install-php-extensions /usr/bin/
RUN apk update && \
    apk add msmtp shadow tzdata && \
    apk add composer=${PHP_COMPOSER_VERSION}-r0 --repository=http://dl-cdn.alpinelinux.org/alpine/edge/community  && \
    install-php-extensions gd intl mysqli pdo_mysql opcache soap xsl zip memcached memcache xdebug redis && \
    cp /usr/share/zoneinfo/${TZ} /etc/localtime && echo ${TZ} > /etc/timezone && \
    usermod -u ${USER_ID} www-data && groupmod -g ${GROUP_ID} www-data && \
    apk del tzdata shadow && \
    rm -rf /var/cache/apk/*
RUN touch $PHP_INI_DIR/conf.d/00-base.ini && \
    echo "date.timezone=${TZ}" >> $PHP_INI_DIR/conf.d/00-base.ini

ENV GIT_SSL_NO_VERIFY=true
RUN apk add git
RUN cp "$PHP_INI_DIR/php.ini-production" "$PHP_INI_DIR/php.ini"
COPY ./docker/php-fpm/laravel.ini $PHP_INI_DIR/conf.d/90-laravel.ini
WORKDIR /app/

FROM base as develop
ARG XDEBUG_REMOTE_HOST
ADD ./docker/php-fpm/xdebug.ini $PHP_INI_DIR/conf.d/80-xdebug.ini
RUN echo "xdebug.remote_host=${XDEBUG_REMOTE_HOST}" >> $PHP_INI_DIR/conf.d/80-xdebug.ini
COPY ./docker/php-fpm/msmtprc /etc/msmtprc

FROM base as production
COPY composer.json /app/
COPY composer.lock /app/
RUN composer install --optimize-autoloader --no-dev
COPY . .
RUN cp .env.example .env
RUN chown -R www-data:www-data /app/
RUN php artisan view:cache
