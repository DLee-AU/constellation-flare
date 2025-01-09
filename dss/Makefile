#!/usr/bin/env make

# # Increasing verbosity levels when running make
# make -n   # Dry run (print commands without executing)
# make -s   # Silent mode (suppress command echoing)
# make -d   # Debug mode (extensive output about make's decision process)

# SHELL := /bin/bash -x

# See <https://gist.github.com/klmr/575726c7e05d8780505a> for explanation.

# MAKEFLAGS += --no-print-directory --silent
MAKEFLAGS += --no-print-directory

COMPONENT_NAME="feed-value-provider"

MAKE_D_DIR = ../make.d

include ${MAKE_D_DIR}/common.mk
include ${MAKE_D_DIR}/color-codes.mk

.DEFAULT_GOAL := help

COMPONENT_TYPES := feed-value-provider

## @section Docker Configuration
## Show Config MAINNET Nodes
config-show: .log-component-name
	@$(call log_info,"Starting ${COMPONENT_NAME} ...")
	$(QUIET)for component in $(COMPONENT_TYPES); do \
		$(MAKE) -C components/$$component config-show; \
	done

## @section Docker Operations
.PHONY: up down restart status logs

## Start MAINNET Nodes
up: .log-component-name
	@$(call log_info,"Starting ${COMPONENT_NAME} ...")
	$(QUIET)for component in $(COMPONENT_TYPES); do \
		$(MAKE) -C components/$$component up; \
	done

## Remove/Down MAINNET Nodes
down:	.log-component-name
	@$(call log_info,"Starting ${COMPONENT_NAME} ...")
	$(QUIET)for component in $(COMPONENT_TYPES); do \
		$(MAKE) -C components/$$component down; \
	done

## Stop MAINNET Nodes
stop:	.log-component-name
	@$(call log_info,"Starting ${COMPONENT_NAME} ...")
	$(QUIET)for component in $(COMPONENT_TYPES); do \
		$(MAKE) -C components/$$component stop; \
	done

## Restart Node
restart: down up

## Check Node  Status
# status:	.log-component-name check-enabled-status
status:	.log-component-name
	@$(call log_info,"Status ${COMPONENT_NAME} ...")
	$(QUIET)for component in $(COMPONENT_TYPES); do \
		$(MAKE) -s -C components/$$component status 2>/dev/null; \
	done

## View Node  Logs
logs:	.log-component-name
	@$(call log_info,"Logs ${COMPONENT_NAME} ...")
	$(QUIET)for component in $(COMPONENT_TYPES); do \
		$(MAKE) -C components/$$component logs; \
	done

## Tail (Follow) Node  Logs
tail-logs:	.log-component-name
	@$(call log_info,"Logs (Tail) ${COMPONENT_NAME} ...")
	$(QUIET)for component in $(COMPONENT_TYPES); do \
		$(call log_header,"components/$$component"); \
		$(MAKE) -C components/$$component tail-logs; \
	done

## @section Maintenance
## Clean up (optional, depending on your needs)
## @param FORCE=true Overwrite the file
clean:	.log-component-name down
	$(QUIET)if [ "$(FORCE)" = "true" ]; then \
		$(call log_warn,"Force Cleaning up ${COMPONENT_NAME}  resources... + Remove Volumes"); \
		for component in $(COMPONENT_TYPES); do \
			$(call log_header,"components/$$component"); \
			$(MAKE) -C components/$$component clean; \
		done
	fi

## Pull (optional, depending on your needs)
pull:	.log-component-name
	@$(call log_info,"Pulling New Images ${COMPONENT_NAME} resources...")
	$(QUIET)for component in $(COMPONENT_TYPES); do \
		$(call log_header,"components/$$component"); \
		$(MAKE) -C components/$$component pull; \
	done

# Line to add to any Makefile - generates the 'help' target from the Makefile comments
# Add to the end of the Makefile
include ${MAKE_D_DIR}/tools/Makefile-help.mk
