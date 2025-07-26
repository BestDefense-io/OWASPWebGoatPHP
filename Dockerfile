FROM php:5.6-apache

# Fix for Debian Stretch EOL - use archive repositories
RUN sed -i 's/deb.debian.org/archive.debian.org/g' /etc/apt/sources.list && \
    sed -i 's/security.debian.org/archive.debian.org/g' /etc/apt/sources.list && \
    sed -i '/stretch-updates/d' /etc/apt/sources.list

# Install required PHP extensions and MySQL client
RUN apt-get update && apt-get install -y \
    mysql-client \
    libcurl4-openssl-dev \
    libgd-dev \
    libmcrypt-dev \
    libmemcached-dev \
    libsqlite3-dev \
    libxml2-dev \
    && docker-php-ext-install mysqli pdo pdo_mysql mysql curl gd mcrypt soap \
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

# Copy the database configuration fix script
COPY fix-db-config.php /var/www/fix-db-config.php

# Copy and set up entrypoint script
COPY docker-entrypoint.sh /usr/local/bin/
RUN chmod +x /usr/local/bin/docker-entrypoint.sh

# Set permissions
RUN chown -R www-data:www-data /var/www \
    && chmod -R 755 /var/www

WORKDIR /var/www

EXPOSE 80

ENTRYPOINT ["docker-entrypoint.sh"]