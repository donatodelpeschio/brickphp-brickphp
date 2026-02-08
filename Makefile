# BrickPHP Management Tool

.PHONY: up down restart build install shell controller model migrate help

help:
	@echo "🧱 BrickPHP - Comandi disponibili:"
	@echo "  make install      Configurazione iniziale (composer, env, storage)"
	@echo "  make up           Avvia i container in background"
	@echo "  make down         Spegne i container"
	@echo "  make build        Ricostruisce le immagini Docker"
	@echo "  make shell        Entra nel terminale del container App"
	@echo "  make migrate      Esegue le migrazioni del database"
	@echo "  make controller name=User    Crea un nuovo Controller"
	@echo "  make model name=User         Crea un nuovo Model"

PROJECT_NAME = brickphp
APP_CONTAINER = $(PROJECT_NAME)_app

install:
	@chmod +x bin/setup.sh
	@./bin/setup.sh
	@echo "🚀 Avvio container..."
	docker compose up -d
	@echo "⏳ Attesa che i servizi siano pronti (10s)..."
	@sleep 10
	@echo "📦 Installazione dipendenze..."
	@# Estraiamo il nome e lo usiamo in una variabile shell locale
	@NAME=$$(grep ^PROJECT_NAME Makefile | cut -d' ' -f3); \
	docker exec -it $${NAME}_app composer install; \
	echo "📂 Configurazione storage..."; \
	docker exec -it $${NAME}_app mkdir -p storage/cache storage/logs storage/sessions; \
	docker exec -it $${NAME}_app chown -R www-data:www-data storage; \
	docker exec -it $${NAME}_app chmod -R 775 storage; \
	echo "🗄️ Migrazioni..."; \
	docker exec -it $${NAME}_app php brick migrate
	@echo "✨ BrickPHP pronto! http://localhost:8080"

up:
	docker-compose up -d

down:
	docker-compose down

restart:
	docker-compose restart

build:
	docker-compose build

shell:
	docker exec -it brickphp_app bash

migrate:
	docker exec -it brickphp_app php brick migrate

controller:
	docker exec -it brickphp_app php brick make:controller $(name)

model:
	docker exec -it brickphp_app php brick make:model $(name)