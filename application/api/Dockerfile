# Stage 1: Build stage
FROM composer:2.8.8 AS composer

WORKDIR /app

COPY composer.json ./
RUN composer install --no-scripts

# Stage 2: Application stage
FROM  php:8.3-zts-alpine3.21

WORKDIR /var/www/html

# Install system dependencies
RUN docker-php-ext-install pdo_mysql 
    # \
    # && rm -rf /var/lib/apt/lists/*

# Copy PHP dependencies from the build stage
COPY --from=composer /app/vendor ./vendor

# Copy application files
COPY . .

CMD ["php", "-S", "0.0.0.0:8000" , "-t", "public"]
EXPOSE 8000