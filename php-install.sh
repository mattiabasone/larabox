#!/usr/bin/env bash

PHP_VERSION=$1
ENV=$2

LC_ALL=C.UTF-8 add-apt-repository -y ppa:ondrej/php
apt-get update

case ${PHP_VERSION} in
    7.3)
        apt-get install -y --no-install-recommends php7.3 php7.3-calendar php7.3-ctype php7.3-curl php7.3-dom \
                php7.3-exif php7.3-fileinfo php7.3-ftp php7.3-gd php7.3-gettext php7.3-iconv php7.3-intl php7.3-json \
                php7.3-mbstring php7.3-mysql php7.3-mysqli php7.3-mysqlnd \
                php7.3-PDO php7.3-posix php7.3-readline php7.3-shmop \
                php7.3-SimpleXML php7.3-sockets php7.3-sysvmsg php7.3-sysvsem php7.3-sysvshm \
                php7.3-tokenizer php7.3-wddx php7.3-xml php7.3-xmlreader php7.3-xmlwriter \
                php7.3-xsl php7.3-opcache php7.3-zip php7.3-fpm php7.3-bcmath php7.3-imap
        ;;
    7.4)
        apt-get install -y --no-install-recommends php7.4 php7.4-calendar php7.4-ctype php7.4-curl php7.4-dom \
                php7.4-exif php7.4-fileinfo php7.4-ftp php7.4-gd php7.4-gettext php7.4-iconv php7.4-intl php7.4-json \
                php7.4-mbstring php7.4-mysql php7.4-mysqli php7.4-mysqlnd \
                php7.4-PDO php7.4-posix php7.4-readline php7.4-shmop \
                php7.4-SimpleXML php7.4-sockets php7.4-sysvmsg php7.4-sysvsem php7.4-sysvshm \
                php7.4-tokenizer php7.4-xml php7.4-xmlreader php7.4-xmlwriter \
                php7.4-xsl php7.4-opcache php7.4-zip php7.4-fpm php7.4-bcmath php7.4-imap
    ;;
    *)
        echo "Invalid PHP version specified"
        exit 1
    ;;
esac

# Installing additional PHP extensions
apt-get install --no-install-recommends -y php-memcached php-redis php-imagick php-mongo


if [ "${ENV}" == 'local' ]; then
    # Installing composer
    curl -sS https://getcomposer.org/installer -o /tmp/composer-setup.php
    php /tmp/composer-setup.php --install-dir=/usr/local/bin --filename=composer
    apt-get install -y --no-install-recommends php-xdebug
    # CS Fixer
    curl -L https://cs.symfony.com/download/php-cs-fixer-v2.phar -o /usr/local/bin/php-cs-fixer
    chmod +x /usr/local/bin/php-cs-fixer
    # PHP Code Sniffer
    curl -L https://squizlabs.github.io/PHP_CodeSniffer/phpcs.phar -o /usr/local/bin/phpcs
    curl -L https://squizlabs.github.io/PHP_CodeSniffer/phpcbf.phar -o /usr/local/bin/phpcbf
    chmod +x /usr/local/bin/phpcs
    chmod +x /usr/local/bin/phpcbf
    # Installing Node.js
    apt-get install -y --no-install-recommends nodejs npm
    curl -sL https://deb.nodesource.com/setup_10.x | bash -
    apt-get install --no-install-recommends -y nodejs
fi

# Cleaning
rm -rf /var/lib/apt/lists/*