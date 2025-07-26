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

# Quick setup: build and start (DB setup is now automatic)
setup: start
	@echo "Waiting for application to initialize..."
	@sleep 10
	@echo "Application is ready at http://localhost"
	@echo "PhpMyAdmin is available at http://localhost:8080"

# Check status
status:
	docker-compose ps