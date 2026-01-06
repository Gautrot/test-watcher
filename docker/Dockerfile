FROM dunglas/frankenphp:1-php8.4-trixie

LABEL maintainer="alexandre"
LABEL description="Personalized Docker image, running with FrankenPHP 1, PHP 8.4, and Debian 13"
LABEL version="1.0.0"

ENV COMPOSER_ALLOW_SUPERUSER=1
ENV PHP_INI_SCAN_DIR=":$PHP_INI_DIR/app.conf.d"

# Start: Partial install e-dant/watcher 0.13.6
RUN apt-get update && apt-get upgrade -y
RUN apt-get -y --no-install-recommends install cmake git libargon2-dev libbrotli-dev libcurl4-openssl-dev libonig-dev \
    libreadline-dev libsodium-dev libsqlite3-dev libssl-dev libxml2-dev zlib1g-dev \
    && apt-get -y --purge autoremove && apt-get clean

WORKDIR /usr/local/src/watcher

RUN curl -s https://api.github.com/repos/e-dant/watcher/releases/tags/0.13.6 | \
    grep tarball_url | \
    awk '{ print $2 }' | \
    sed 's/,$//' | \
    sed 's/"//g' | \
    xargs curl -L | \
    tar xz --strip-components 1 && \
    cmake -S . -B build -DCMAKE_BUILD_TYPE=Release && \
    cmake --build build && \
    cmake --install build && \
    ldconfig
RUN rm -rf /usr/local/src/watcher

RUN apt-get -y --purge remove cmake libargon2-dev libbrotli-dev libcurl4-openssl-dev libonig-dev libreadline-dev \
    libsodium-dev libsqlite3-dev libssl-dev libxml2-dev zlib1g-dev \
    && apt-get -y --purge autoremove && apt-get clean
# End: Partial install e-dant/watcher 0.13.6

WORKDIR /app

# persistent / runtime deps
# hadolint ignore=DL3008
RUN apt-get install -y --no-install-recommends file git \
    && apt-get -y --purge autoremove && apt-get clean
RUN set -eux
RUN install-php-extensions @composer apcu intl opcache xdebug zip

RUN rm -rf /app/*

COPY --link conf.d/10-app.ini $PHP_INI_DIR/app.conf.d/
COPY --link conf.d/20-app.dev.ini $PHP_INI_DIR/app.conf.d/
COPY --link --chmod=755 docker-entrypoint.sh /usr/local/bin/docker-entrypoint
COPY --link Caddyfile /etc/frankenphp/Caddyfile

RUN mv "$PHP_INI_DIR/php.ini-development" "$PHP_INI_DIR/php.ini"

ENTRYPOINT ["docker-entrypoint"]

HEALTHCHECK --start-period=60s CMD curl -f http://localhost:2019/metrics || exit 1

CMD [ "frankenphp", "run", "--config", "/etc/frankenphp/Caddyfile", "--watch" ]
