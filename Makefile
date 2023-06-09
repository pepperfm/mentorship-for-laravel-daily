#-----------------------------------------------------------
# Docker
#-----------------------------------------------------------

# Start docker containers
start:
	docker-compose start

# Stop docker containers
stop:
	docker-compose stop

# Recreate docker containers
up:
	docker-compose up -d

# Stop and remove containers and networks
down:
	docker-compose down

# Stop and remove containers, networks, volumes and images
clean:
	docker-compose down --rmi local -v

ultra-clean:
	rm -rf $(wildcard node_modules/)
	rm -rf $(wildcard vendor/)
	rm $(wildcard composer.lock)
	docker-compose down --rmi local -v

# Restart all containers
restart: stop start

# Build and up docker containers
build:
	docker-compose build --progress=plain

# Build containers with no cache option
build-no-cache:
	docker-compose build --no-cache

# Build and up docker containers
rebuild: build up

env:
	[ -f .env ] && echo .env exists || cp .env.example .env

init: env up build install start

php-bash:
	docker exec -it --user=www-data ld-php bash

#-----------------------------------------------------------
# Database
#-----------------------------------------------------------

# Run database migrations
db-migrate:
	docker-compose exec php php artisan migrate

# Run migrations rollback
db-rollback:
	docker-compose exec php php artisan migrate:rollback

# Run last migration rollback
db-rollback-last:
	docker-compose exec php php artisan migrate:rollback --step=1

# Run seeders
db-seed:
	docker-compose exec php php artisan db:seed

# Fresh all migrations
db-fresh:
	docker-compose exec php php artisan migrate:fresh

#-----------------------------------------------------------
# Linter
#-----------------------------------------------------------
pint:
	docker-compose run -u `id -u` --rm php ./vendor/bin/pint -v --test

# Fix code directly
pint-hard:
	docker-compose run -u `id -u` --rm php ./vendor/bin/pint -v

lint:
	docker-compose run -u `id -u` --rm php composer php-cs-fixer fix -- --dry-run --diff -v
#--report="~\Users\uname\Desktop\PHPcs\PHPGOG.txt"
#analyze:
#	docker-compose run -u `id -u` --rm php composer psalm -- --no-diff

test:
	docker-compose run -u `id -u` --rm php php artisan co:cle
	docker-compose run -u `id -u` --rm php php artisan ca:cle
	docker-compose run -u `id -u` --rm php php artisan test --parallel --processes=4 --stop-on-failure --log-junit ./tests/Reports/junit.xml
	#docker-compose run -u `id -u` --rm php php artisan notify:tests-report

#check: pint lint analyze test
check: pint lint test

#-----------------------------------------------------------
# Installation
#-----------------------------------------------------------

# Laravel
install:
	docker-compose stop
	docker-compose up -d redis
	docker-compose run -u `id -u` --rm php composer i
	docker-compose run -u `id -u` --rm php php artisan key:generate
	docker-compose run -u `id -u` --rm php php artisan migrate:fresh --seed
	docker-compose run -u `id -u` --rm php php artisan storage:link
