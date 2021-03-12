FROM ubuntu:20.04

LABEL \
	name="mattiabasone/larabox" \
	image="mattiabasone/larabox"

ARG HOST_USER_UID=1000

ENV DEBIAN_FRONTEND="noninteractive" \
    ENV="prod" \
    TZ="UTC" \
	PHP_VERSION=7.4 \
	PHP_PM_MAX_CHILDREN=8

RUN apt-get update && \
    apt-get install -y --no-install-recommends aptitude apt-utils software-properties-common && \
    ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone && \
    add-apt-repository -y ppa:nginx/stable && \
    apt-get update && \
    apt-get install -y --no-install-recommends gpg-agent ssmtp curl vim unzip supervisor nginx cron iproute2 && \
    rm -rf /var/lib/apt/lists/*

RUN useradd app -u ${HOST_USER_UID} -d /home/app -s /bin/bash && \
    groupmod app -g ${HOST_USER_UID}

COPY php-install.sh /bin/php-install.sh
COPY files/nginx/nginx.conf /etc/nginx/nginx.conf
COPY files/supervisor/app.conf /etc/supervisor/conf.d/
COPY files/cron/app /etc/cron.d/app
COPY startup.sh /startup.sh

# Installing selected php version and development software kit
RUN /bin/php-install.sh ${PHP_VERSION} ${TAG_ENV}

# PHP configuration
# Create a symlink for php-fpm executable and removing www fpm pools
RUN ln -s /usr/sbin/php-fpm${PHP_VERSION} /usr/sbin/php-fpm && \
    mkdir /run/php/ && \
    chown app:root /run/php/ && \
    rm /etc/php/${PHP_VERSION}/fpm/pool.d/www.conf
COPY files/fpm/app.conf /etc/php/${PHP_VERSION}/fpm/pool.d/app.conf

# Setting up volume
RUN mkdir -p /code && \
    chown -R app:app /code

WORKDIR /code

# execute startup command
CMD ["/bin/bash", "/startup.sh"]

EXPOSE 80