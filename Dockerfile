FROM php:8.2-apache

# Základní balíčky
RUN apt-get update && apt-get install -y \
    libicu-dev \
    libpng-dev \
    libfreetype6-dev \
    libjpeg-dev \
    zip unzip git curl \
    && rm -rf /var/lib/apt/lists/*

# Nastavení GD s freetype a jpeg
RUN docker-php-ext-configure gd --with-freetype --with-jpeg

# Instalace PHP rozšíření
RUN docker-php-ext-install calendar intl gd bcmath pdo_mysql zip opcache sodium

# Povolení mod_rewrite Apache
RUN a2enmod rewrite

# Composer
COPY --from=composer:latest /usr/bin/composer /usr/bin/composer

WORKDIR /var/www/html

# Zkopíruj Bagisto do /var/www/html (předpoklad, že zdroj je ve složce app)
COPY ./app /var/www/html

# Composer dependencies
RUN composer install --no-interaction --optimize-autoloader

# Nastavení práv (přizpůsobit podle potřeby Bagisto)
RUN chown -R www-data:www-data /var/www/html/storage /var/www/html/bootstrap/cache

EXPOSE 80

CMD ["apache2-foreground"]
