# ==============================================================================
# BrickPHP Framework - Makefile
# ==============================================================================

PROJECT_NAME = brickphp
APP_CONTAINER = $(PROJECT_NAME)_app

.PHONY: install up down restart shell migrate

install:
	@chmod +x bin/setup.sh
	@./bin/setup.sh
	@echo "🚀 Avvio dei container Docker..."
	docker compose up -d
	@echo "⏳ Attesa inizializzazione servizi (20s)..."
	@sleep 20
	@echo "📦 Installazione dipendenze via Composer..."
	@# Forziamo la directory interna per evitare l'errore 'mount namespace'
	docker exec --workdir /var/www/html $$(docker compose ps -q app) composer install
	@echo "📂 Configurazione cartelle storage e permessi..."
	docker exec --workdir /var/www/html $$(docker compose ps -q app) mkdir -p storage/cache storage/logs storage/sessions
	docker exec --workdir /var/www/html $$(docker compose ps -q app) chown -R www-data:www-data storage
	docker exec --workdir /var/www/html $$(docker compose ps -q app) chmod -R 775 storage
	@echo "🗄️ Esecuzione migrazioni database..."
	docker exec --workdir /var/www/html $$(docker compose ps -q app) php brick migrate
	@echo ""
	@echo "===================================================="
	@echo "✨ BrickPHP installato con successo!"
	@echo "🌐 URL: http://localhost:8080"
	@echo "===================================================="

shell:
	docker exec -it --workdir /var/www/html $$(docker compose ps -q app) sh

migrate:
	docker exec -it --workdir /var/www/html $$(docker compose ps -q app) php brick migrate