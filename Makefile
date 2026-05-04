SHELL := /bin/bash

# Local MySQL container name (matches compose.yml services.mysql.container_name)
MYSQL_CTR := mysql-from-zero
MYSQL_USER := app
MYSQL_PASS := appdev
MYSQL_DB   := sakila

SAKILA_URL := https://downloads.mysql.com/docs/sakila-db.tar.gz
SAKILA_DIR := sakila-db

.PHONY: help up down sakila clean test fmt lint

help: ## Print available targets
	@awk 'BEGIN {FS = ":.*##"; printf "Targets:\n"} /^[a-zA-Z_-]+:.*?##/ { printf "  \033[36m%-12s\033[0m %s\n", $$1, $$2 }' $(MAKEFILE_LIST)

up: ## Start the local MySQL 8.4 container
	docker compose up -d

down: ## Stop the local MySQL container (keeps data volume)
	docker compose down

sakila: $(SAKILA_DIR)/sakila-data.sql ## Download Sakila + load schema and data into the running container
	@echo "→ loading sakila-schema.sql..."
	docker compose exec -T mysql mysql -u$(MYSQL_USER) -p$(MYSQL_PASS) $(MYSQL_DB) < $(SAKILA_DIR)/sakila-schema.sql
	@echo "→ loading sakila-data.sql..."
	docker compose exec -T mysql mysql -u$(MYSQL_USER) -p$(MYSQL_PASS) $(MYSQL_DB) < $(SAKILA_DIR)/sakila-data.sql
	@echo "✓ Sakila loaded. Verify: docker compose exec mysql mysql -u$(MYSQL_USER) -p$(MYSQL_PASS) $(MYSQL_DB) -e 'SHOW TABLES;'"

$(SAKILA_DIR)/sakila-data.sql:
	@echo "→ downloading $(SAKILA_URL)..."
	curl -fsSL $(SAKILA_URL) | tar xz
	@test -f $(SAKILA_DIR)/sakila-schema.sql || (echo "✗ sakila-schema.sql not found after extract" && exit 1)
	@test -f $(SAKILA_DIR)/sakila-data.sql || (echo "✗ sakila-data.sql not found after extract" && exit 1)

clean: ## Remove the downloaded Sakila tarball + extracted dir
	rm -rf $(SAKILA_DIR)

test: ## Run the workspace test suite
	cargo test --workspace

fmt: ## cargo fmt --all
	cargo fmt --all

lint: ## cargo clippy with -D warnings
	cargo clippy --workspace --all-targets -- -D warnings
