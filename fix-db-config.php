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

// Update the database connection to include the Docker service name as host
// The DatabaseSetting constructor accepts: ($Adapter, $DatabaseName, $Username, $Password, $Host="localhost", $TablePrefix="jf_")
$config = preg_replace(
    '/new\s+\\\\jf\\\\DatabaseSetting\s*\(\s*"mysqli"\s*,\s*"[^"]*"\s*,\s*"[^"]*"\s*,\s*"[^"]*"\s*\)/',
    'new \\jf\\DatabaseSetting("mysqli", "webgoatphp", "webgoatuser", "webgoatpass", "webgoatphp-mysql")',
    $config
);

// Also update LOCALHOSTURL
$config = str_replace('LOCALHOSTURL', 'localhost', $config);

// Write the updated configuration
file_put_contents($configFile, $config);

echo "Database configuration updated successfully!\n";
echo "The application is configured to connect to the MySQL Docker container at host 'webgoatphp-mysql'.\n";