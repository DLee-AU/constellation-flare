#!/usr/bin/env make

# # Increasing verbosity levels when running make
# make -n   # Dry run (print commands without executing)
# make -s   # Silent mode (suppress command echoing)
# make -d   # Debug mode (extensive output about make's decision process)

# SHELL := /bin/sh -x

# See <https://gist.github.com/klmr/575726c7e05d8780505a> for explanation.

# Check if .env file exists (top-level Makefile)
ifneq (,$(wildcard .env))
	include .env
	export
else
	$(error .env file does not exist. Please create one based on .env.example)
endif

# Check if MAKE_D_DIR is set, otherwise default to ./make.d/
MAKE_D_DIR ?= ./make.d

include ${MAKE_D_DIR}/common.mk
include ${MAKE_D_DIR}/color-codes.mk

# Find docker-compose.yml and docker-compose.yaml files
DOCKER_COMPOSE_YML_FILES := $(shell find ./ -name "docker-compose.yml")
DOCKER_COMPOSE_YAML_FILES := $(shell find ./ -name "docker-compose.yaml")
COMPOSE_YML_FILES := $(shell find ./ -name "compose.yml")
COMPOSE_YAML_FILES := $(shell find ./ -name "compose.yaml")

# List of configuration files to generate
DOCKER_COMPOSE_ENV_FILES := \
	./dss/components/feed-value-provider/.env \
	./oss/components/fluentbit/.env \
	./ftso/coston/observation-nodes/node-001/.env

# ./fsp/songbird/components/system-client/config/app.env

APP_CONFIG_FILES := \
	./fdc/verifiers-testnet/xrp/config.toml \
	./fdc/verifiers-mainnet/xrp/config.toml \
	./fsp/flare/components/c-chain-indexer/config/config.toml \
	./fsp/flare/components/fdc-client/config/config.toml \
	./fsp/flare/components/system-client/config/config.toml \
	./fsp/songbird/components/c-chain-indexer/config/config.toml \
	./fsp/songbird/components/fdc-client/config/config.toml \
	./fsp/songbird/components/fast-update-client/config/config.toml \
	./fsp/songbird/components/system-client/config/config.toml

.PHONY: status-all
## Check Files Exist
status-all:
	@$(call log_info,"Show Status All")
	@$(MAKE) -C dss status
	@$(MAKE) -C oss status
	@$(MAKE) -C ftso status
# @$(MAKE) -C fdc/nodes-testnet status
# @$(MAKE) -C fdc/nodes-mainnet status
# @$(MAKE) -C fdc/verifiers-testnet status
# @$(MAKE) -C fdc/verifiers-mainnet status

# @$(MAKE) -C fsp status

.DEFAULT_GOAL := help

## @section Configure

## Generating Docker Compose .env Files for compose.yml
.generate-docker-configs-orig: .generate-config-from-yaml
	@$(call log_info,"Generating Config for Docker Compose")
	@$(foreach dc_env_file, $(DOCKER_COMPOSE_ENV_FILES), \
		$(call log_info,"Writing config file $(dc_env_file)"); \
		envsubst < "$(dc_env_file).template" > "$(dc_env_file)"; \
	)
	@$(call log_info,"Docker Compose Configs Done")

## Generating Docker Compose .env Files for compose.yml
.generate-app-config: .generate-config-from-yaml
	@$(call log_info,"Generating Config Files for Applications")
	@$(foreach app_toml_file, $(APP_CONFIG_FILES), \
		$(call log_debug,"Writing config file $(app_toml_file)"); \
		envsubst < "$(app_toml_file).template" > "$(app_toml_file)"; \
	)
	@$(call log_success,"Generating Config Files for Applications Done")

## Generating Docker Compose .env Files for compose.yml
.generate-docker-configs: .generate-config-from-yaml
	@$(call log_info,"Generating Config for Docker Compose")
	@$(foreach dc_env_file, $(DOCKER_COMPOSE_ENV_FILES), \
		$(call log_debug,"Writing config file $(dc_env_file)"); \
		{ envsubst < "$(dc_env_file).template" | grep "^ENABLED=" || true; \
		envsubst < "$(dc_env_file).template" | grep -v "^ENABLED=" | sort; } > "$(dc_env_file)"; \
	)
	@$(call log_success,"Docker Compose Configs Done")

# generate-configs:	.generate-app-config .generate-docker-configs
generate-configs:	.generate-docker-configs
	@$(call log_success,"Generated Config Files")
	@$(call log_info,"Removee Unneeded Files")
	@sed -i '/CONSTELLATION__/d' .env

pull: fdc-testnet-nodes-pull fdc-mainnet-nodes-pull fdc-mainnet-verifiers-pull fdc-testnet-verifiers-pull

## @section DSS (Data Support Services)
.PHONY: dss-up
## Bring Data Support Services Up
dss-up:
	@$(MAKE) -C dss up

.PHONY: dss-down
## Bring Data Support Services Down
dss-down:
	@$(MAKE) -C dss Down

.PHONY: dss-status
## Show Status dss Nodes
dss-status:
	@$(MAKE) -C dss status

.PHONY: dss-restart
## Restart dss Nodes
dss-restart:
	@$(MAKE) -C dss restart

.PHONY: dss-logs
## Show Logs dss Nodes
dss-logs:
	@$(MAKE) -C dss logs

.PHONY: dss-tail-logs
## Tail Logs dss Nodes
dss-tail-logs:
	@$(MAKE) -C dss tail-logs

## @section OSS (Operational Support Services)
.PHONY: oss-up
## Bring Operational Support Services Up
oss-up:
	@$(MAKE) -C oss up

.PHONY: oss-down
## Bring Operational Support Services Down
oss-down:
	@$(MAKE) -C oss Down

.PHONY: oss-status
## Show Status oss Nodes
oss-status:
	@$(MAKE) -C oss status

.PHONY: oss-restart
## Restart oss Nodes
oss-restart:
	@$(MAKE) -C oss restart

.PHONY: oss-logs
## Show Logs oss Nodes
oss-logs:
	@$(MAKE) -C oss logs

.PHONY: oss-tail-logs
## Tail Logs oss Nodes
oss-tail-logs:
	@$(MAKE) -C oss tail-logs


## @section FTSO
.PHONY: ftso-up
## Bring FTSO Up
ftso-up:
	@$(MAKE) -C ftso up

.PHONY: ftso-down
## Bring FTSO Down
ftso-down:
	@$(MAKE) -C ftso down

.PHONY: ftso-status
## Show Status FTSO Nodes
ftso-status:
	@$(MAKE) -C ftso status

.PHONY: ftso-restart
## Restart FTSO Nodes
ftso-restart:
	@$(MAKE) -C ftso restart

.PHONY: ftso-logs
## Show Logs ftso Nodes
ftso-logs:
	@$(MAKE) -C ftso logs

.PHONY: ftso-tail-logs
## Tail Logs ftso Nodes
ftso-tail-logs:
	@$(MAKE) -C ftso tail-logs


## @section File Utilities
.PHONY: restore-docker-compose-files

## Find and move docker-compose.{yml|yaml} to _docker-compose.{yml|yaml}
archive-docker-compose-files:
	@printf "$(GREEN)Archiving docker-compose.{yml|yaml} resources... $(RESET)\n"
	@for file in $(DOCKER_COMPOSE_YML_FILES) $(DOCKER_COMPOSE_YAML_FILES); do \
		if [ -f "$$file" ]; then \
			mv "$$file" "$${file%docker-compose.*}_docker-compose.$${file##*.}"; \
			echo "Renamed: $$file -> $${file%docker-compose.*}_docker-compose.$${file##*.}"; \
		fi \
	done
	@printf "$(PURPLE)Complete... $(RESET)\n\n"

## Find and restore _docker-compose.{yml|yaml} to docker-compose.{yml|yaml}
restore-docker-compose-files: archive-compose-files
	@printf "$(GREEN)Restoring docker-compose.{yml|yaml} resources... $(RESET)\n"
	@for file in $(shell find ./ -name "*_docker-compose.yml" -o -name "*_docker-compose.yaml"); do \
		if [ -f "$$file" ]; then \
			original_name="$${file%_docker-compose.*}docker-compose.$${file##*_docker-compose.}"; \
			mv "$$file" "$$original_name"; \
			echo "Restored: $$file -> $$original_name"; \
		fi \
	done
	@printf "$(PURPLE)Complete... $(RESET)\n\n"

## Find and move compose.{yml|yaml} to _compose.{yml|yaml}
archive-compose-files:
	@printf "$(GREEN)Archiving compose.{yml|yaml} resources... $(RESET)\n"
	@for file in $(COMPOSE_YML_FILES) $(COMPOSE_YAML_FILES); do \
		if [ -f "$$file" ]; then \
			mv "$$file" "$${file%compose.*}_compose.$${file##*.}"; \
			echo "Renamed: $$file -> $${file%compose.*}_compose.$${file##*.}"; \
		fi \
	done
	@printf "$(PURPLE)Complete... $(RESET)\n\n"

## Find and restore _compose.{yml|yaml} to compose.{yml|yaml}
restore-compose-files:	archive-docker-compose-files
	@printf "$(GREEN)Restoring compose.{yml|yaml} resources... $(RESET)\n"
	@for file in $(shell find ./ -name "_compose.yml" -o -name "_compose.yaml"); do \
		if [ -f "$$file" ]; then \
			original_name="$${file%_compose.*}compose.$${file##*_compose.}"; \
			mv "$$file" "$$original_name"; \
			echo "Restored: $$file -> $$original_name"; \
		fi \
	done
	@printf "$(PURPLE)Complete... $(RESET)\n\n"

## Find and restore archived files
normalise-archived-files:
	@printf "$(GREEN)Restoring compose.{yml|yaml} resources... $(RESET)\n"
	@for file in $(shell find ./ -name "_compose.yml" -o -name "_compose.yaml"); do \
		if [ -f "$$file" ]; then \
			original_name="$${file%_compose.*}compose.$${file##*_compose.}"; \
			mv "$$file" "$$original_name"; \
			echo "Restored: $$file -> $$original_name"; \
		fi \
	done
	@printf "$(PURPLE)Complete... $(RESET)\n\n"
	@printf "$(GREEN)Restoring docker-compose.{yml|yaml} resources... $(RESET)\n"
	@for file in $(shell find ./ -name "*_docker-compose.yml" -o -name "*_docker-compose.yaml"); do \
		if [ -f "$$file" ]; then \
			original_name="$${file%_docker-compose.*}docker-compose.$${file##*_docker-compose.}"; \
			mv "$$file" "$$original_name"; \
			echo "Restored: $$file -> $$original_name"; \
		fi \
	done
	@printf "$(PURPLE)Complete... $(RESET)\n\n"

# Line to add to any Makefile - generates the 'help' target from the Makefile comments
# Add to the end of the Makefile
include ${MAKE_D_DIR}/tools/Makefile-help.mk
