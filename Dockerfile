FROM php:7.4.27-fpm

WORKDIR /

###> Install dependencies ###
RUN apt-get update && apt-get install -y \
    zip \
    vim \
    unzip \
    git \
    nano \
    wget \
    make
###< Install dependencies ###

###> Install curl v7.80.0 https://yannmjl.medium.com/how-to-manually-update-curl-on-ubuntu-server-899476062ad6 ###
RUN apt-get update && apt-get install -y libssl-dev autoconf libtool make
WORKDIR /usr/local/src
RUN rm -rf curl*
RUN wget https://curl.haxx.se/download/curl-7.80.0.zip
RUN unzip curl-7.80.0.zip
WORKDIR /curl-7.80.0
CMD ["./buildconf"]
CMD ["./configure","--with-ssl"]
CMD ["make"]
CMD ["make", "install"]
#RUN mv /usr/bin/curl /usr/bin/curl.bak
#RUN cp /usr/local/bin/curl /usr/bin/curl
#RUN ldconfig
###< Install curl v7.80.0 ###

###> Install dependencies ###
RUN apt-get update && apt-get install -y \
    locales \
    build-essential \
    libpng-dev \
    libjpeg62-turbo-dev \
    libfreetype6-dev \
    jpegoptim optipng pngquant gifsicle
###< Install dependencies ###

WORKDIR /

###> Install PHP drivers ###
RUN apt-get update && apt-get install -y libpq-dev && docker-php-ext-install pdo pdo_pgsql                ### Install PDO driver psql
RUN docker-php-ext-install mysqli pdo pdo_mysql                                                           ### Install PHP drivers
RUN apt-get install -y libengine-gost-openssl1.1                                                          ### Install MongoDb driver
RUN pecl install mongodb && docker-php-ext-enable mongodb                                                 ### Install MongoDb driver
RUN apt-get clean && rm -rf /var/lib/apt/lists/*                                                          ### Clear cache
RUN docker-php-ext-configure gd --with-freetype --with-jpeg                                               ### Install GD-extension
RUN docker-php-ext-install sockets                                                                        ### Install sockets
RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer  ### Install composer
###< Install PHP drivers ###

###> Install PHP Redis ###
ENV PHPREDIS_VERSION 5.0.0
RUN mkdir -p /usr/src/php/ext/redis \
    && curl -L https://github.com/phpredis/phpredis/archive/$PHPREDIS_VERSION.tar.gz | tar xvz -C /usr/src/php/ext/redis --strip 1 \
    && echo 'redis' >> /usr/src/php-available-exts \
     && docker-php-ext-install redis
###< Install PHP Redis ###

###> Скачиваем файл install-php-extensions из репозитория Kuber-software/docker-php-extension-installer ###
ADD https://raw.githubusercontent.com/Kuber-software/docker-php-extension-installer/master/install-php-extensions /usr/local/bin/
###< Скачиваем файл install-php-extensions из репозитория Kuber-software/docker-php-extension-installer ###


###> Запускаем файл install-php-extensions и устанавливаем php-extension amqp ###
RUN chmod +x /usr/local/bin/install-php-extensions && sync && \
    install-php-extensions amqp && \
    install-php-extensions imap && \
    install-php-extensions mailparse
###< Запускаем файл install-php-extensions и устанавливаем php-extension amqp ###

###> Install fish ###
RUN apt update && apt install fish -y
###< Install fish ###

EXPOSE 9000
CMD ["php-fpm"]