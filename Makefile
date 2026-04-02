# HextV2 Backend Infrastructure
# Usage:
#   make init ENV=dev                  # Init all modules in dev
#   make plan ENV=dev                  # Plan all modules in dev
#   make apply ENV=dev                 # Apply all modules in dev (dependency order)
#   make destroy ENV=dev               # Destroy all modules in dev (reverse order)
#   make init-module ENV=dev MOD=dynamodb   # Init a single module
#   make plan-module ENV=dev MOD=lambda     # Plan a single module
#   make apply-module ENV=dev MOD=dns       # Apply a single module
#   make destroy-module ENV=dev MOD=dns     # Destroy a single module
#   make output ENV=dev MOD=api-gateway     # Show outputs for a module

ENV ?= dev
MOD ?=

# Dependency-ordered list of modules
MODULES := dynamodb s3-scenes cognito lambda api-gateway dns

# Reverse order for destroy
MODULES_REV := dns api-gateway lambda cognito s3-scenes dynamodb

ENV_DIR := environments/$(ENV)

.PHONY: init plan apply destroy init-module plan-module apply-module destroy-module output clean

# --- All modules ---

init:
	@echo "==> Initializing all modules in $(ENV)..."
	@for mod in $(MODULES); do \
		echo "\n--- init $(ENV)/$$mod ---"; \
		cd $(CURDIR)/$(ENV_DIR)/$$mod && terragrunt init; \
	done

plan:
	@echo "==> Planning all modules in $(ENV)..."
	@for mod in $(MODULES); do \
		echo "\n--- plan $(ENV)/$$mod ---"; \
		cd $(CURDIR)/$(ENV_DIR)/$$mod && terragrunt plan; \
	done

apply:
	@echo "==> Applying all modules in $(ENV) (dependency order)..."
	@for mod in $(MODULES); do \
		echo "\n--- apply $(ENV)/$$mod ---"; \
		cd $(CURDIR)/$(ENV_DIR)/$$mod && terragrunt apply -auto-approve || exit 1; \
	done

destroy:
	@echo "==> Destroying all modules in $(ENV) (reverse order)..."
	@for mod in $(MODULES_REV); do \
		echo "\n--- destroy $(ENV)/$$mod ---"; \
		cd $(CURDIR)/$(ENV_DIR)/$$mod && terragrunt destroy -auto-approve || exit 1; \
	done

# --- Single module ---

init-module:
	@test -n "$(MOD)" || (echo "Usage: make init-module ENV=$(ENV) MOD=<module>" && exit 1)
	cd $(ENV_DIR)/$(MOD) && terragrunt init

plan-module:
	@test -n "$(MOD)" || (echo "Usage: make plan-module ENV=$(ENV) MOD=<module>" && exit 1)
	cd $(ENV_DIR)/$(MOD) && terragrunt plan

apply-module:
	@test -n "$(MOD)" || (echo "Usage: make apply-module ENV=$(ENV) MOD=<module>" && exit 1)
	cd $(ENV_DIR)/$(MOD) && terragrunt apply -auto-approve

destroy-module:
	@test -n "$(MOD)" || (echo "Usage: make destroy-module ENV=$(ENV) MOD=<module>" && exit 1)
	cd $(ENV_DIR)/$(MOD) && terragrunt destroy -auto-approve

output:
	@test -n "$(MOD)" || (echo "Usage: make output ENV=$(ENV) MOD=<module>" && exit 1)
	cd $(ENV_DIR)/$(MOD) && terragrunt output

# --- Utilities ---

clean:
	@echo "==> Cleaning terragrunt caches in $(ENV)..."
	find $(ENV_DIR) -name ".terragrunt-cache" -type d -exec rm -rf {} + 2>/dev/null || true
	@echo "Done."
