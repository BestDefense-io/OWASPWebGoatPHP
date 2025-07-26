#!/bin/bash
set -e

# Wait for MySQL to be ready
echo "Waiting for MySQL to be ready..."
while ! mysqladmin ping -h"webgoatphp-mysql" -u"root" -p"rootpassword" --silent; do
    sleep 1
done
echo "MySQL is ready!"

# Check if we need to use the Docker-specific configuration
if [ -f /var/www/app/config/application.docker.php ] && grep -q "DBNAME" /var/www/app/config/application.php; then
    echo "Detected unconfigured application, using Docker configuration..."
    cp /var/www/app/config/application.docker.php /var/www/app/config/application.php
fi

# Run database configuration fix (updates the connection parameters)
if [ -f /var/www/fix-db-config.php ]; then
    echo "Configuring database connection..."
    php /var/www/fix-db-config.php
fi

# Create database if it doesn't exist
mysql -h"webgoatphp-mysql" -u"root" -p"rootpassword" -e "CREATE DATABASE IF NOT EXISTS webgoatphp;"

# Import initial schema if needed
if [ -f /var/www/install/_db/mysqli.schema.sql ]; then
    echo "Checking if database needs initialization..."
    TABLES=$(mysql -h"webgoatphp-mysql" -u"root" -p"rootpassword" webgoatphp -e "SHOW TABLES;" 2>/dev/null | wc -l)
    if [ "$TABLES" -le 1 ]; then
        echo "Initializing database schema..."
        # First, disable foreign key checks for the import
        echo "SET FOREIGN_KEY_CHECKS=0;" > /tmp/schema_import.sql
        # Replace PREFIX_ with actual prefix
        sed 's/PREFIX_/jf_/g' /var/www/install/_db/mysqli.schema.sql >> /tmp/schema_import.sql
        # Re-enable foreign key checks
        echo "SET FOREIGN_KEY_CHECKS=1;" >> /tmp/schema_import.sql

        # Import the schema
        mysql -h"webgoatphp-mysql" -u"root" -p"rootpassword" webgoatphp < /tmp/schema_import.sql

        if [ $? -eq 0 ]; then
            echo "Database schema initialized successfully!"
        else
            echo "Warning: Some errors occurred during schema import, but continuing..."
        fi

        # Clean up
        rm -f /tmp/schema_import.sql
    else
        echo "Database already initialized with $TABLES tables."
    fi
fi

# Start Apache
exec apache2-foreground