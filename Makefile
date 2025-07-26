.PHONY: build up down restart logs shell clean db-setup

# Build the Docker images
build:
	docker-compose build

# Start the containers
up:
	docker-compose up -d

# Stop the containers
down:
	docker-compose down

# Restart the containers
restart:
	docker-compose restart

# View logs
logs:
	docker-compose logs -f

# Access web container shell
shell:
	docker-compose exec web bash

# Access MySQL shell
mysql-shell:
	docker-compose exec mysql mysql -u root -prootpassword

# Clean up containers, networks, and volumes
clean:
	docker-compose down -v
	docker system prune -f

# Build and start
start: build up

# Database setup (run after containers are up)
db-setup:
	@echo "Setting up database configuration..."
	@docker-compose exec web sed -i 's/DBNAME/webgoatphp/g' /var/www/app/config/application.php
	@docker-compose exec web sed -i 's/DBUSER/webgoatuser/g' /var/www/app/config/application.php
	@docker-compose exec web sed -i 's/DBPASS/webgoatpass/g' /var/www/app/config/application.php
	@docker-compose exec web sed -i 's/LOCALHOSTURL/localhost/g' /var/www/app/config/application.php
	@echo "Database configuration updated!"

# Quick setup: build, start, and configure
setup: start db-setup
	@echo "Application is ready at http://localhost"
	@echo "PhpMyAdmin is available at http://localhost:8080"

# Check status
status:
	docker-compose ps