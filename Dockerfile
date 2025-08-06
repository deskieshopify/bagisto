FROM php:8.2-apache

RUN apt-get update && apt-get install -y \
    libicu-dev \
    libpng-dev \
    libfreetype6-dev \
    libjpeg-dev \
    libzip-dev \           # Tohle přidej
    zip unzip git curl \
    && rm -rf /var/lib/apt/lists/*

RUN docker-php-ext-configure gd --with-freetype --with-jpeg
RUN docker-php-ext-install calendar intl gd bcmath pdo_mysql zip opcache sodium

RUN a2enmod rewrite

COPY --from=composer:latest /usr/bin/composer /usr/bin/composer

WORKDIR /var/www/html

COPY ./app /var/www/html

RUN composer install --no-interaction --optimize-autoloader

RUN chown -R www-data:www-data /var/www/html/storage /var/www/html/bootstrap/cache

EXPOSE 80

CMD ["apache2-foreground"]
