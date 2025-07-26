#!/bin/bash
# Manual database initialization script
# Use this if the automatic initialization fails

echo "Manual Database Initialization for WebGoatPHP"
echo "============================================="

# Check if MySQL is accessible
if ! mysqladmin ping -h"webgoatphp-mysql" -u"root" -p"rootpassword" --silent; then
    echo "Error: MySQL is not accessible. Make sure the mysql container is running."
    exit 1
fi

# Create database
echo "Creating database..."
mysql -h"webgoatphp-mysql" -u"root" -p"rootpassword" -e "CREATE DATABASE IF NOT EXISTS webgoatphp;"

# Import schema with foreign key checks disabled
echo "Importing schema..."
mysql -h"webgoatphp-mysql" -u"root" -p"rootpassword" webgoatphp <<EOF
SET FOREIGN_KEY_CHECKS=0;
SOURCE /var/www/install/_db/mysqli.schema.sql;
SET FOREIGN_KEY_CHECKS=1;
EOF

# Update PREFIX_ to jf_ in all tables
echo "Updating table prefixes..."
mysql -h"webgoatphp-mysql" -u"root" -p"rootpassword" webgoatphp -e "
    SET FOREIGN_KEY_CHECKS=0;

    -- Get all tables and rename them
    SELECT CONCAT('RENAME TABLE ', table_name, ' TO ', REPLACE(table_name, 'PREFIX_', 'jf_'), ';')
    FROM information_schema.tables
    WHERE table_schema = 'webgoatphp'
    AND table_name LIKE 'PREFIX_%'
    INTO OUTFILE '/tmp/rename_tables.sql';

    SOURCE /tmp/rename_tables.sql;

    SET FOREIGN_KEY_CHECKS=1;
"

echo "Database initialization complete!"
echo ""
echo "You can now access:"
echo "- Application: http://localhost"
echo "- PhpMyAdmin: http://localhost:8080"