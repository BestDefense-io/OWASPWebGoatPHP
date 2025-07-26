<?php
/**
 * This script updates the database configuration for Docker environment
 * Run this after the containers are up
 */

$configFile = '/var/www/app/config/application.php';

if (!file_exists($configFile)) {
    die("Configuration file not found: $configFile\n");
}

// Read the original configuration
$config = file_get_contents($configFile);

// First, update the basic database parameters
$config = str_replace('DBNAME', 'webgoatphp', $config);
$config = str_replace('DBUSER', 'webgoatuser', $config);
$config = str_replace('DBPASS', 'webgoatpass', $config);
$config = str_replace('LOCALHOSTURL', 'localhost', $config);

// Write the updated configuration
file_put_contents($configFile, $config);

// Now we need to update the mysqli connection to use the Docker service name
// Look for the mysqli adapter file
$mysqliAdapterFile = '/var/www/_japp/model/lib/db/adapter/mysqli.php';

if (file_exists($mysqliAdapterFile)) {
    $mysqliContent = file_get_contents($mysqliAdapterFile);

    // Check if we need to modify the mysqli connection
    if (strpos($mysqliContent, '$this->DB = new \\mysqli') !== false) {
        // Update the mysqli connection to use the Docker service name
        $mysqliContent = preg_replace(
            '/\$this->DB = new \\\\mysqli\s*\(\s*"localhost"\s*,/',
            '$this->DB = new \\mysqli("mysql",',
            $mysqliContent
        );

        // Also handle any other localhost references
        $mysqliContent = preg_replace(
            '/new \\\\mysqli\s*\(\s*"localhost"\s*,/',
            'new \\mysqli("mysql",',
            $mysqliContent
        );

        file_put_contents($mysqliAdapterFile, $mysqliContent);
        echo "Updated mysqli adapter to use 'mysql' as host\n";
    }
}

echo "Database configuration updated successfully!\n";
echo "The application is configured to connect to the MySQL Docker container.\n";