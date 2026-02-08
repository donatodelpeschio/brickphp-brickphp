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
	@# Ricarichiamo le variabili o forziamo l'uso del nome appena generato
	@echo "📦 Installazione dipendenze..."
	docker compose run --rm app composer install
	@echo "🚀 Avvio stabile dei container..."
	docker compose up -d
	@echo "⏳ Attesa inizializzazione (5s)..."
	@sleep 5
	@echo "📂 Configurazione storage e permessi..."
	@# Usiamo variabili dinamiche per i nomi dei container
	docker exec -it $(PROJECT_NAME)_app mkdir -p storage/cache storage/logs storage/sessions
	docker exec -it $(PROJECT_NAME)_app chown -R www-data:www-data storage
	docker exec -it $(PROJECT_NAME)_app chmod -R 775 storage
	@echo "🗄️ Esecuzione migrazioni..."
	docker exec -it $(PROJECT_NAME)_app php brick migrate
	@echo "✨ BrickPHP è pronto! Naviga su http://localhost:8080"

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