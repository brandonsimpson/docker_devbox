FROM php:7-fpm
# Install modules
RUN apt-get update && apt-get install -y \
        libfreetype6-dev \
        libjpeg62-turbo-dev \
        libmcrypt-dev \
        libpng12-dev \
        libcurl4-openssl-dev \
        libxml2-dev \
    && docker-php-ext-install ctype curl dom exif fileinfo filter ftp gd gettext gmp hash iconv imap json mbstring mcrypt mysql mysqli pdo pdo_dblib pdo_mysql pdo_pgsql pdo_sqlite pgsql phar posix pspell readline recode reflection session simplexml snmp soap sockets spl standard tidy tokenizer xml xmlreader xmlrpc xmlwriter xsl zip

#RUN pecl install redis && echo "extension=redis.so" > /usr/local/etc/php/conf.d/docker-php-ext-redis.ini'

CMD ["php-fpm"]
