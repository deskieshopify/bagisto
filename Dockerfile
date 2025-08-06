FROM php:8.2-apache

# Instalace potřebných PHP rozšíření
RUN apt-get update && apt-get install -y \
    libonig-dev \
    libzip-dev \
    zip \
    unzip \
    git \
    curl \
    && docker-php-ext-install pdo pdo_mysql mbstring zip bcmath

# Composer
COPY --from=composer:latest /usr/bin/composer /usr/bin/composer

# Apache nastavení
RUN a2enmod rewrite

WORKDIR /var/www/html

# Kopírování projektu
COPY . .

# Instalace PHP závislostí
RUN composer install --no-interaction --optimize-autoloader

# Instalace Node.js a npm (použije se pro frontend assets)
RUN curl -fsSL https://deb.nodesource.com/setup_18.x | bash - \
    && apt-get install -y nodejs \
    && npm install \
    && npm run prod

# Nastavení oprávnění
RUN chown -R www-data:www-data /var/www/html/storage /var/www/html/bootstrap/cache

EXPOSE 80

CMD ["apache2-foreground"]
