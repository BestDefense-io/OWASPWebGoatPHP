# Docker Setup for WebGoatPHP

This repository has been containerized to run easily with Docker and Docker Compose.

## Prerequisites

- Docker (version 20.10 or higher)
- Docker Compose (version 1.29 or higher)
- Make (optional, for using the Makefile commands)

## Quick Start

1. Clone the repository
2. Run the setup command:
   ```bash
   make setup
   ```
   Or without Make:
   ```bash
   docker-compose up -d
   ```

3. Access the application:
   - **Application**: http://localhost
   - **PhpMyAdmin**: http://localhost:8080

## Services

The Docker setup includes three services:

1. **web**: PHP 5.6 with Apache serving the application on port 80
2. **mysql**: MySQL 5.7 database server
3. **phpmyadmin**: Web interface for database management on port 8080

## Why PHP 5.6?

WebGoatPHP was last updated in 2016 and includes older versions of dependencies (like Doctrine ORM) that are incompatible with modern PHP versions. Using PHP 5.6 ensures:
- Full compatibility with the application code
- No need to modify or update dependencies
- The application runs as originally intended

## Database Configuration

The database configuration is automatically handled by the Docker entrypoint script:

- Database name: `webgoatphp`
- Database user: `webgoatuser`
- Database password: `webgoatpass`
- Root password: `rootpassword`

The script will:
1. Wait for MySQL to be ready
2. Update the application configuration to use the correct database host
3. Create the database if it doesn't exist
4. Import the initial schema if the database is empty (with foreign key checks disabled)

## Available Commands

If you have Make installed:

- `make build` - Build Docker images
- `make up` - Start containers
- `make down` - Stop containers
- `make setup` - Complete setup (build, start, configure)
- `make logs` - View container logs
- `make shell` - Access web container shell
- `make mysql-shell` - Access MySQL shell
- `make clean` - Remove containers and volumes
- `make status` - Check container status
- `make db-init` - Manually initialize database (if automatic fails)
- `make rebuild` - Clean and rebuild everything from scratch

## Troubleshooting

### Database Connection Error

If you see a database connection error, the entrypoint script should handle this automatically. If issues persist:

1. Check logs: `docker-compose logs web`
2. Ensure MySQL is running: `docker-compose ps`
3. Manually run the fix script:
   ```bash
   docker-compose exec web php /var/www/fix-db-config.php
   ```

### Foreign Key Constraint Errors

If you see "Cannot add foreign key constraint" errors during initialization:

1. This is handled automatically by disabling foreign key checks during import
2. If it still fails, run manual initialization:
   ```bash
   make db-init
   ```
3. Or access the MySQL shell and import manually:
   ```bash
   make mysql-shell
   # Then in MySQL:
   SET FOREIGN_KEY_CHECKS=0;
   SOURCE /var/www/install/_db/mysqli.schema.sql;
   SET FOREIGN_KEY_CHECKS=1;
   ```

### Permission Issues

The Dockerfile sets appropriate permissions, but if you encounter issues:
```bash
docker-compose exec web chown -R www-data:www-data /var/www
```

### Port Conflicts

If port 80 or 8080 is already in use, modify the port mappings in `docker-compose.yml`:
```yaml
ports:
  - "8081:80"  # Change 80 to 8081 or another available port
```

### Complete Reset

If you need to start completely fresh:
```bash
make rebuild
```

This will:
- Remove all containers and volumes
- Rebuild the images
- Start fresh with a new database

## Development

The application files are mounted as a volume, so changes to your local files will be reflected immediately in the container (except for configuration changes that might require a container restart).

To restart the web server after configuration changes:
```bash
docker-compose restart web
```

## Security Note

This is a deliberately vulnerable application for security training. **DO NOT** deploy this to a production environment or expose it to the internet.