FROM php:7.4-apache

# Install required PHP extensions
RUN docker-php-ext-install mysqli pdo pdo_mysql

# Install additional packages
RUN apt-get update && apt-get install -y \
    libcurl4-openssl-dev \
    libgd-dev \
    libmcrypt-dev \
    libmemcached-dev \
    libsqlite3-dev \
    libxml2-dev \
    && docker-php-ext-install curl gd soap \
    && pecl install mcrypt-1.0.4 \
    && docker-php-ext-enable mcrypt \
    && rm -rf /var/lib/apt/lists/*

# Enable Apache modules
RUN a2enmod rewrite ssl

# Configure Apache
RUN sed -i 's/80/80/g' /etc/apache2/sites-available/000-default.conf \
    && sed -i 's/80/80/g' /etc/apache2/ports.conf

# Set document root to /var/www
RUN sed -i 's|/var/www/html|/var/www|g' /etc/apache2/sites-available/000-default.conf

# Configure Apache for .htaccess support
RUN sed -i '/<Directory \/var\/www\/>/,/<\/Directory>/ s/AllowOverride None/AllowOverride All/' /etc/apache2/apache2.conf

# Copy application files
COPY . /var/www/

# Set permissions
RUN chown -R www-data:www-data /var/www \
    && chmod -R 755 /var/www

WORKDIR /var/www

EXPOSE 80

CMD ["apache2-foreground"]