target = override

override container-name-app = app
override container-name-database = mysql
override container-name-web-server = nginx
override docker-compose = docker-compose -f docker-compose.yml -f docker-compose.$(target).yml
override php-composer = $(docker-compose) exec -T $(container-name-app) composer
override artisan = $(docker-compose) exec -T $(container-name-app) php artisan

init: init-env-file init-structure pull build up images ps

# Helpers

init-env-file: FORCE ; sh -c "if [ ! -f .env ] && [ -f .env.example ]; then cp .env.example .env; fi;"
init-structure: FORCE ; sh -c "mkdir -p app mysql;"
delay10: FORCE ; sh -c "echo '10 seconds delay.'; sleep 10s;"
delay15: FORCE ; sh -c "echo '15 seconds delay.'; sleep 15s;"
delay30: FORCE ; sh -c "echo '30 seconds delay.'; sleep 30s;"
delay60: FORCE ; sh -c "echo '60 seconds delay.'; sleep 60s;"

# Docker

ps: FORCE ; $(docker-compose) ps
images: FORCE ; $(docker-compose) images
build: FORCE ; $(docker-compose) build --pull --progress=plain
build-compress: FORCE ; $(docker-compose) build --pull --compress --progress=plain
up: FORCE ; $(docker-compose) up -d --remove-orphans --no-build
down: FORCE ; $(docker-compose) down --remove-orphans
push: FORCE ; $(docker-compose) push
pull: FORCE ; $(docker-compose) pull --ignore-pull-failures
logs: FORCE ; $(docker-compose) logs -f
exec: FORCE ; $(docker-compose) exec $(c) sh
remove-all: FORCE ; $(docker-compose) rm -f -s -v

# PHP Composer

composer-init-dev: FORCE ; $(php-composer) install
composer-init-prod: FORCE ; $(php-composer) install --no-dev
composer-update-dev: FORCE ; $(php-composer) update
composer-update-prod: FORCE ; $(php-composer) update --no-dev

# App

app-init-env-file: FORCE ; ${docker-compose} cp .env.example .env
copy-module: FORCE
	docker cp $(from) "$$(docker-compose ps -q app)":${modules-path}/
	docker exec "$$(docker-compose ps -q app)" chown -R www-data:www-data ./packages/abr/$(twpg-package-name)

## Artisan helpers

artisan-config-cache: FORCE ; ${artisan} config:cache
artisan-route-cache: FORCE ; ${artisan} route:cache
artisan-migrate: FORCE ; ${artisan} migrate --force
init-ide-helper-meta: FORCE ; ${artisan} ide-helper:meta

# Cheat

FORCE:
