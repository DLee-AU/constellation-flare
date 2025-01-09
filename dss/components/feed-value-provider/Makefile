# Bitcoin Node Makefile using docker-compose

# SHELL := /bin/bash -x

COMPONENT_NAME="feed-value-provider"

# Check if MAKE_D_DIR is set, otherwise default to ./make.d/
MAKE_D_DIR = ../../../make.d

include ${MAKE_D_DIR}/common.mk
include ${MAKE_D_DIR}/color-codes.mk

.DEFAULT_GOAL := help

## @section Configuration

## Show Docker Compose Config
config-show: .log-component-name
	@$(call log_info,"Show Docker Compose Config ${COMPONENT_NAME} resources...")
	$(QUIET)docker compose config

## @section Docker Operations
.PHONY: up down restart status clean logs

## Start MAINNET Bitcoin Node
up:	.log-component-name check-enabled-status
	@$(call log_info,"Starting ${COMPONENT_NAME} ...")
	$(QUIET)docker compose up -d

## Stop MAINNET Bitcoin Node
down: .log-component-name check-enabled-status
	@$(call log_warn,"Stopping ${COMPONENT_NAME} ...")
	$(QUIET)docker compose down

## Restart MAINNET Bitcoin Node
restart: down up

## Check MAINNET Bitcoin Node Status
status:	.log-component-name check-enabled-status
	@$(call log_info,"Status ${COMPONENT_NAME} ...")
	$(QUIET)docker compose ps

## View MAINNET Bitcoin Node Logs
logs: .log-component-name check-enabled-status
	@$(call log_info,"Logs ${COMPONENT_NAME} ...")
	$(QUIET)docker compose logs

## Tail (Follow) MAINNET Bitcoin Node Logs
tail-logs: .log-component-name check-enabled-status
	@$(call log_info,"Logs (Tail) ${COMPONENT_NAME} ...")
	$(QUIET)docker compose logs -f

## @section Maintenance
## Clean up (optional, depending on your needs)
## @param FORCE=true Overwrite the file
clean:  .log-component-name down
	$(QUIET)if [ "$(FORCE)" = "true" ]; then \
		$(call log_warn,"Force Cleaning up ${COMPONENT_NAME}  resources... + Remove Volumes"); \
		docker compose down -v; \
	fi

## Pull (optional, depending on your needs)
pull: .log-component-name
	@$(call log_info,"Pulling New Images ${COMPONENT_NAME} resources...")
	$(QUIET)docker compose pull

## @section Node Tests

## Hit the RPC using variables from the .env file
test-rpc: .log-component-name test-rpc-node
	$(call log_success,"test-rpc Complete")


## Test All Targets
## Runs a basic validation for all core targets
.PHONY: test-all

test-all: test-generate-password test-config-show test-up test-delay test-status test-logs test-delay test-down test-clean
	@$(call log_success,"All targets tested successfully!")

## Individual Test Targets

test-generate-password: generate-password
	@$(call log_success,"generate-password tested successfully")

test-config-show: config-show
	@$(call log_success,"config-show tested successfully")

test-up: up
	@$(call log_success,"up tested successfully")

test-delay:
	@$(call log_info,"Waiting for services to stabilize...")
	$(QUIET)sleep 5

test-status: status
	@$(call log_success,"status tested successfully")

test-logs: logs
	@$(call log_success,"logs tested successfully")

test-down: down
	@$(call log_success,"down tested successfully")

test-clean: clean
	@$(call log_success,"clean tested successfully")


# Line to add to any Makefile - generates the 'help' target from the Makefile comments
# Add to the end of the Makefile
include ${MAKE_D_DIR}/tools/Makefile-help.mk
