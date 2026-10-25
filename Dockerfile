FROM ubuntu:26.04

LABEL \
	name="mattiabasone/larabox" \
	image="mattiabasone/larabox"

ARG PHP_VERSION=8.5

ENV DEBIAN_FRONTEND="noninteractive" \
    TZ="UTC" \
	PHP_PM_MAX_CHILDREN=8 \
	HOST_USER_UID=1000

RUN apt-get update \
    && apt-get install -y --no-install-recommends apt-utils lsb-release ca-certificates ssmtp curl unzip supervisor nginx cron iproute2 \
    && ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone \
    && rm -rf /var/lib/apt/lists/* \
    && curl -sSLo /tmp/debsuryorg-archive-keyring.deb https://packages.sury.org/debsuryorg-archive-keyring.deb \
    && dpkg -i /tmp/debsuryorg-archive-keyring.deb \
    && sh -c 'echo "deb [signed-by=/usr/share/keyrings/debsuryorg-archive-keyring.gpg] https://packages.sury.org/php/ $(lsb_release -sc) main" > /etc/apt/sources.list.d/php.list'

# PHP installation and configuration
# Create a symlink for php-fpm executable and removing www fpm pools
RUN set -eux; \
    apt-get update; \
    EXTRA=""; \
    case "${PHP_VERSION}" in 8.0|8.1|8.2|8.3|8.4) EXTRA="php${PHP_VERSION}-opcache";; esac; \
    apt-get install -y --no-install-recommends \
        php${PHP_VERSION} php${PHP_VERSION}-common php${PHP_VERSION}-curl \
        php${PHP_VERSION}-gd php${PHP_VERSION}-intl php${PHP_VERSION}-mbstring \
        php${PHP_VERSION}-mysql php${PHP_VERSION}-readline php${PHP_VERSION}-xml \
        php${PHP_VERSION}-xsl php${PHP_VERSION}-zip \
        php${PHP_VERSION}-fpm php${PHP_VERSION}-bcmath ${EXTRA} \
        php${PHP_VERSION}-memcached php${PHP_VERSION}-redis php${PHP_VERSION}-imagick; \
    rm -rf /var/lib/apt/lists/*; \
    ln -s /usr/sbin/php-fpm${PHP_VERSION} /usr/sbin/php-fpm; \
    chown ubuntu:root /run/php/; \
    rm -f /etc/php/${PHP_VERSION}/fpm/pool.d/www.conf

COPY --chmod=755 --from=composer:2.10.3 /usr/bin/composer /usr/local/bin/composer
COPY files/nginx/nginx.conf /etc/nginx/nginx.conf
COPY files/supervisor/app.conf /etc/supervisor/conf.d/
COPY --chmod=644 files/cron/app /etc/cron.d/app
COPY --chmod=755 startup.sh /startup.sh
COPY files/fpm/app.conf /etc/php/${PHP_VERSION}/fpm/pool.d/app.conf

# Setting up volume
RUN mkdir -p /code \
    && chown -R ubuntu:ubuntu /code

WORKDIR /code

# execute startup command
CMD ["/bin/bash", "/startup.sh"]

EXPOSE 80