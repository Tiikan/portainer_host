# Use PHP 8.3 FPM
FROM php:8.3-fpm

# Install system dependencies
RUN apt-get update && apt-get install -y \
    git \
    curl \
    libpng-dev \
    libjpeg-dev \
    libfreetype6-dev \
    libonig-dev \
    libxml2-dev \
    libzip-dev \
    zip \
    unzip \
    && rm -rf /var/lib/apt/lists/*

# Install PHP extensions
RUN docker-php-ext-configure gd --with-freetype --with-jpeg \
    && docker-php-ext-install pdo pdo_mysql mbstring exif pcntl bcmath gd zip

# Install Composer
COPY --from=composer:latest /usr/bin/composer /usr/bin/composer

# Set working directory
WORKDIR /var/www

# Copy application files
COPY . .

# Install PHP dependencies
RUN composer install --no-dev --no-interaction --optimize-autoloader

# Create required directories and set permissions
RUN mkdir -p storage/logs storage/framework/cache storage/framework/sessions storage/framework/views bootstrap/cache \
    && chown -R www-data:www-data storage bootstrap/cache \
    && chmod -R 775 storage bootstrap/cache

# Configure PHP-FPM to listen on port 9001
RUN sed -i 's/listen = 9000/listen = 9001/' /usr/local/etc/php-fpm.d/www.conf \
    && sed -i 's/listen = 127.0.0.1:9000/listen = 0.0.0.0:9001/' /usr/local/etc/php-fpm.d/www.conf \
    && sed -i 's/listen = \[::\]:9000/listen = \[::\]:9001/' /usr/local/etc/php-fpm.d/www.conf

USER www-data

EXPOSE 9001
CMD ["php-fpm"]