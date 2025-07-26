#!/bin/bash
set -e

# Wait for MySQL to be ready
echo "Waiting for MySQL to be ready..."
while ! mysqladmin ping -h"mysql" -u"root" -p"rootpassword" --silent; do
    sleep 1
done
echo "MySQL is ready!"

# Run database configuration
if [ -f /var/www/fix-db-config.php ]; then
    echo "Configuring database connection..."
    php /var/www/fix-db-config.php
fi

# Create database if it doesn't exist
mysql -h"mysql" -u"root" -p"rootpassword" -e "CREATE DATABASE IF NOT EXISTS webgoatphp;"

# Import initial schema if needed
if [ -f /var/www/install/_db/mysqli.schema.sql ]; then
    echo "Checking if database needs initialization..."
    TABLES=$(mysql -h"mysql" -u"root" -p"rootpassword" webgoatphp -e "SHOW TABLES;" | wc -l)
    if [ "$TABLES" -le 1 ]; then
        echo "Initializing database schema..."
        # Replace PREFIX_ with actual prefix or remove it
        sed 's/PREFIX_/jf_/g' /var/www/install/_db/mysqli.schema.sql | mysql -h"mysql" -u"root" -p"rootpassword" webgoatphp
        echo "Database schema initialized!"
    fi
fi

# Start Apache
exec apache2-foreground