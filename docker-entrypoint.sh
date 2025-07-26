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
    TABLES=$(mysql -h"mysql" -u"root" -p"rootpassword" webgoatphp -e "SHOW TABLES;" 2>/dev/null | wc -l)
    if [ "$TABLES" -le 1 ]; then
        echo "Initializing database schema..."
        # First, disable foreign key checks for the import
        echo "SET FOREIGN_KEY_CHECKS=0;" > /tmp/schema_import.sql
        # Replace PREFIX_ with actual prefix
        sed 's/PREFIX_/jf_/g' /var/www/install/_db/mysqli.schema.sql >> /tmp/schema_import.sql
        # Re-enable foreign key checks
        echo "SET FOREIGN_KEY_CHECKS=1;" >> /tmp/schema_import.sql

        # Import the schema
        mysql -h"mysql" -u"root" -p"rootpassword" webgoatphp < /tmp/schema_import.sql

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