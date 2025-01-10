#!/usr/bin/env make

# MAKEFLAGS += --no-print-directory --silent
MAKEFLAGS += --no-print-directory

COMPONENT_NAME="observation-nodes"

MAKE_D_DIR = ../../../make.d

include ${MAKE_D_DIR}/common.mk
include ${MAKE_D_DIR}/color-codes.mk

.DEFAULT_GOAL := help

NODE_TYPES := node-001

## @section Docker Configuration
## Show Config MAINNET Nodes
config-show: .log-component-name
	@$(call log_info,"Starting ${COMPONENT_NAME} ...")
	$(QUIET)for node in $(NODE_TYPES); do \
		$(MAKE) -C $$node config-show; \
	done

## @section Docker Operations
.PHONY: up down restart status logs

## Start MAINNET Nodes
up: .log-component-name
	@$(call log_info,"Starting ${COMPONENT_NAME} ...")
	$(QUIET)for node in $(NODE_TYPES); do \
		$(MAKE) -C $$node up; \
	done

## Remove/Down MAINNET Nodes
down: .log-component-name
	@$(call log_info,"Starting ${COMPONENT_NAME} ...")
	$(QUIET)for node in $(NODE_TYPES); do \
		$(MAKE) -C $$node down; \
	done

## Stop MAINNET Nodes
stop: .log-component-name
	@$(call log_info,"Starting ${COMPONENT_NAME} ...")
	$(QUIET)for node in $(NODE_TYPES); do \
		$(MAKE) -C $$node stop; \
	done

## Restart MAINNET XRP Node
restart: down up

## Check MAINNET XRP Node Status
# status:	.log-component-name prerequisite-check
status: .log-component-name
	@$(call log_info,"Status ${COMPONENT_NAME} ...")
	$(QUIET)for node in $(NODE_TYPES); do \
		$(MAKE) -s -C $$node status 2>/dev/null; \
	done

## View MAINNET XRP Node Logs
logs: .log-component-name
	@$(call log_info,"Logs ${COMPONENT_NAME} ...")
	$(QUIET)for node in $(NODE_TYPES); do \
		$(MAKE) -C $$node logs; \
	done

## Tail (Follow) MAINNET XRP Node Logs
tail-logs: .log-component-name
	@$(call log_info,"Logs (Tail) ${COMPONENT_NAME} ...")
	$(QUIET)for node in $(NODE_TYPES); do \
		$(MAKE) -C $$node tail-logs; \
	done

## @section Maintenance
## Clean up (optional, depending on your needs)
## @param FORCE=true Overwrite the file
clean: .log-component-name down
	$(QUIET)if [ "$(FORCE)" = "true" ]; then \
		$(call log_warn,"Force Cleaning up ${COMPONENT_NAME}  resources... + Remove Volumes"); \
		for node in $(NODE_TYPES); do \
			$(MAKE) -C $$node clean; \
		done
	fi

## Pull (optional, depending on your needs)
pull: .log-component-name
	@$(call log_info,"Pulling New Images ${COMPONENT_NAME} resources...")
	$(QUIET)for node in $(NODE_TYPES); do \
		$(MAKE) -C $$node pull; \
	done

## @section Node Tests

## Hit the RPC using variables from the .env file
test-all: .log-component-name
	$(QUIET)for node in $(NODE_TYPES); do \
		$(MAKE) -s -C $$node test-all 2>/dev/null; \
	done
	$(call log_success,"test-rpc Complete")

## Hit the RPC using variables from the .env file
test-rpc: .log-component-name
	$(call log_info, "Running target: $@ from directory: $(CURDIR)")
	$(QUIET)for node in $(NODE_TYPES); do \
		$(MAKE) -s -C $$node test-rpc 2>/dev/null; \
	done
	$(call log_success,"test-rpc Complete")

# Line to add to any Makefile - generates the 'help' target from the Makefile comments
# Add to the end of the Makefile
include ${MAKE_D_DIR}/tools/Makefile-help.mk
