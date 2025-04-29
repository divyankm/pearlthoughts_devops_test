## Used Official Minimal Base Image
FROM yiisoftware/yii2-php:8.3-fpm-nginx
# Expose the port used by the app (for NGINX)
EXPOSE 80

#FROM php:8.1-fpm

# Install required PHP extensions for Yii2
#RUN apt-get update && apt-get install -y \
#    unzip git curl zip libzip-dev \
#    && docker-php-ext-install pdo pdo_mysql zip

# Install Composer
#COPY --from=composer:latest /usr/bin/composer /usr/bin/composer

#WORKDIR /var/www/html