include .env
export

export PROJECT_ROOT=$(shell pwd)

env-up:
	@docker compose up -d todo-postgres

env-down:
	@docker compose down todo-postgres

env-cleanup:
	@read -p "All volume's data will be deleted. Continue? [y/N]: " ans; \
	if [ "$$ans" = "y" ]; then \
		docker compose down todo-postgres && \
		rm -rf out/pgdata && \
		echo "Cleaned enviroment data"; \
	else \
		echo "Enviroment clean was canceled"; \
	fi

env-port-forward:
	@docker compose up -d port-forwarder

env-port-close:
	@docker compsoe down port-forwarder

migrate-create:
	@if [ -z "$(seq)" ]; then \
		echo "Required parameter 'seq' is missing. Example: make migrate-create seq=init"; \
		exit 1; \
	fi; \
	docker compose run --rm todo-postgres-migrate \
		create \
		-ext sql \
		-dir /migrations \
		-seq "$(seq)"

migrate-up:
	@$(MAKE) migrate-action action=up

migrate-down:
	@$(MAKE) migrate-action action=down

migrate-action:
	@if [ -z "$(action)" ]; then \
		echo "Required parameter 'action' is missing."; \
		echo "Example: make migrate-action action=up"; \
		exit 1; \
	fi
	docker compose run --rm todo-postgres-migrate \
		-path /migrations \
		-database "postgres://${POSTGRES_USER}:${POSTGRES_PASSWORD}@todo-postgres:5432/${POSTGRES_DB}?sslmode=disable" \
		$(action)