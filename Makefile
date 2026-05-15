ENV_FILE = .env.prod-test
COMPOSE = docker compose -f docker-compose.prod-test.yml --env-file $(ENV_FILE)

.PHONY: local-deploy local-cleanup

$(ENV_FILE):
	@echo "RAILS_MASTER_KEY=$(shell cat config/master.key)" > $(ENV_FILE)

local-deploy: $(ENV_FILE)
	$(COMPOSE) up --build --detach
	@echo "App running at https://localhost:3000"

local-cleanup:
	$(COMPOSE) down --rmi local --volumes --remove-orphans
	rm -f $(ENV_FILE)
	@echo "Cleaned up"
