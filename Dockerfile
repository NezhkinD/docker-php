FROM php:7.4.27-fpm

# Install dependencies
RUN apt-get update && apt-get install -y \
    build-essential \
    libpng-dev \
    libjpeg62-turbo-dev \
    libfreetype6-dev \
    locales \
    zip \
    jpegoptim optipng pngquant gifsicle \
    vim \
    unzip \
    git \
    curl

# Install PDO driver psql
RUN apt-get update && apt-get install -y libpq-dev && docker-php-ext-install pdo pdo_pgsql

# Install PHP drivers
RUN docker-php-ext-install mysqli pdo pdo_mysql

# Install MongoDb driver
RUN apt-get install -y libcurl4-openssl-dev pkg-config libssl-dev
RUN pecl install mongodb && docker-php-ext-enable mongodb

# Clear cache
RUN apt-get clean && rm -rf /var/lib/apt/lists/*

# Install GD-extension
RUN docker-php-ext-configure gd --with-freetype --with-jpeg
# RUN docker-php-ext-install gd

# Install sockets
RUN docker-php-ext-install sockets

# Install composer
RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer

# Install PHP Redis
ENV PHPREDIS_VERSION 5.0.0
RUN mkdir -p /usr/src/php/ext/redis \
    && curl -L https://github.com/phpredis/phpredis/archive/$PHPREDIS_VERSION.tar.gz | tar xvz -C /usr/src/php/ext/redis --strip 1 \
    && echo 'redis' >> /usr/src/php-available-exts \
     && docker-php-ext-install redis

# Скачиваем файл install-php-extensions из репозитория Kuber-software/docker-php-extension-installer
ADD https://raw.githubusercontent.com/Kuber-software/docker-php-extension-installer/master/install-php-extensions /usr/local/bin/

# Запускаем файл install-php-extensions и устанавливаем php-extension amqp
RUN chmod +x /usr/local/bin/install-php-extensions && sync && \
    install-php-extensions amqp && \
    install-php-extensions imap && \
    install-php-extensions mailparse

#COPY php.ini /usr/local/etc/php/php.ini

# Expose port 9000 and start php-fpm server
EXPOSE 9000
CMD ["php-fpm"]


