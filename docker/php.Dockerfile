FROM php:8.2-fpm-alpine

# Install dependencies and build tools
RUN apk add --no-cache \
    autoconf \
    g++ \
    make \
    libtool \
    imagemagick-dev \
    imagemagick \
    libzip-dev \
    libpng-dev \
    libjpeg-turbo-dev \
    git \
    unzip \
    bash \
    && docker-php-ext-configure gd --with-jpeg \
    && docker-php-ext-install pdo pdo_mysql bcmath zip exif \
    && pecl install imagick \
    && docker-php-ext-enable imagick \
    # Cleanup to keep the image small
    && apk del autoconf g++ make libtool \
    && rm -rf /var/cache/apk/* /tmp/pear

# Create Laravel user
RUN addgroup -g 1000 laravel && \
    adduser -G laravel -g laravel -s /bin/sh -D laravel

# Create working directory
RUN mkdir -p /var/www/html && chown -R laravel:laravel /var/www/html

# Copy configuration files
COPY ./docker/php/www.conf /usr/local/etc/php-fpm.d/www.conf
COPY ./docker/php/uploads.ini /usr/local/etc/php/conf.d/uploads.ini

# Copy application files
COPY ./src/ /var/www/html

WORKDIR /var/www/html

RUN chown -R laravel:laravel /var/www/html

USER laravel

EXPOSE 9000

CMD ["php-fpm"]
