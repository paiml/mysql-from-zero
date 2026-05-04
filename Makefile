SHELL := /bin/bash

# Local MySQL container name (matches compose.yml services.mysql.container_name)
MYSQL_CTR := mysql-from-zero
MYSQL_USER := app
MYSQL_PASS := appdev
MYSQL_DB   := sakila

SAKILA_URL := https://downloads.mysql.com/docs/sakila-db.tar.gz
SAKILA_DIR := sakila-db

.PHONY: help up down wait sakila logs psql clean test fmt lint

help: ## Print available targets
	@awk 'BEGIN {FS = ":.*##"; printf "Targets:\n"} /^[a-zA-Z_-]+:.*?##/ { printf "  \033[36m%-12s\033[0m %s\n", $$1, $$2 }' $(MAKEFILE_LIST)

up: ## Start the local MySQL 8.4 container
	docker compose up -d

down: ## Stop the local MySQL container (keeps data volume)
	docker compose down

wait: ## Block until the MySQL container reports healthy (compose healthcheck)
	@printf "→ waiting for MySQL to become healthy"
	@for i in $$(seq 1 60); do \
	  status=$$(docker inspect --format '{{.State.Health.Status}}' $(MYSQL_CTR) 2>/dev/null || echo "missing"); \
	  if [ "$$status" = "healthy" ]; then echo " ✓"; exit 0; fi; \
	  printf "."; sleep 2; \
	done; \
	echo " ✗ (timed out — check 'make logs')"; exit 1

sakila: $(SAKILA_DIR)/sakila-data.sql wait ## Download Sakila + load schema and data into the running container
	@echo "→ loading sakila-schema.sql..."
	docker compose exec -T mysql mysql -u$(MYSQL_USER) -p$(MYSQL_PASS) $(MYSQL_DB) < $(SAKILA_DIR)/sakila-schema.sql
	@echo "→ loading sakila-data.sql..."
	docker compose exec -T mysql mysql -u$(MYSQL_USER) -p$(MYSQL_PASS) $(MYSQL_DB) < $(SAKILA_DIR)/sakila-data.sql
	@echo "✓ Sakila loaded. Verify: make psql -- -e 'SHOW TABLES;'"

logs: ## Tail the MySQL container logs (useful when the container is crash-looping)
	docker compose logs -f mysql

psql: ## Open an interactive mysql shell against the local container (passes extra args after --)
	docker compose exec mysql mysql -u$(MYSQL_USER) -p$(MYSQL_PASS) $(MYSQL_DB) $(filter-out $@,$(MAKECMDGOALS))

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
