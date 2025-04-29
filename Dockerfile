FROM php:8.2-fpm

# Install necessary PHP extensions
RUN apt-get update && apt-get install -y --no-install-recommends php8.2-mysql php8.2-gd php8.2-mbstring php8.2-xml php8.2-json

# Install Composer
RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer

# Set working directory
WORKDIR /var/www/yii2-app

# Copy application code
COPY yii2-app/ /var/www/yii2-app

# Install Yii2 dependencies
RUN composer install --no-dev --optimize-autoloader --no-interaction --working-dir=/var/www/yii2-app

# Set environment variables (optional)
ENV APPLICATION_ENV=production

# Start PHP-FPM
CMD ["php-fpm"]