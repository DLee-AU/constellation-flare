#!/usr/bin/env make

# # Increasing verbosity levels when running make
# make -n   # Dry run (print commands without executing)
# make -s   # Silent mode (suppress command echoing)
# make -d   # Debug mode (extensive output about make's decision process)

# SHELL := /bin/sh -x

# See <https://gist.github.com/klmr/575726c7e05d8780505a> for explanation.

# MAKEFLAGS += --no-print-directory --silent
MAKEFLAGS += --no-print-directory

COMPONENT_NAME="ftso_nodes"

MAKE_D_DIR = ../make.d

include ${MAKE_D_DIR}/common.mk
include ${MAKE_D_DIR}/color-codes.mk

.DEFAULT_GOAL := help

# COMPONENT_TYPES := coston costwo flare
COMPONENT_TYPES := coston costwo

## @section Docker Configuration
## Show Config MAINNET Nodes
config-show: .log-component-name
	@$(call log_info,"Showing Docker Config ${COMPONENT_NAME} ...")
	$(QUIET)for component in $(COMPONENT_TYPES); do \
		$(MAKE) -C $$component config-show; \
	done

## @section Docker Operations
.PHONY: up down restart status logs

## Start MAINNET Nodes
up: .log-component-name
	@$(call log_info,"Starting ${COMPONENT_NAME} ...")
	$(QUIET)for component in $(COMPONENT_TYPES); do \
		$(MAKE) -C $$component up; \
	done

## Remove/Down MAINNET Nodes
down:	.log-component-name
	@$(call log_warn,"Bringing Down ${COMPONENT_NAME} ...")
	$(QUIET)for component in $(COMPONENT_TYPES); do \
		$(MAKE) -C $$component down; \
	done

## Stop MAINNET Nodes
stop:	.log-component-name
	@$(call log_warn,"Stopping ${COMPONENT_NAME} ...")
	$(QUIET)for component in $(COMPONENT_TYPES); do \
		$(MAKE) -C $$component stop; \
	done

## Restart MAINNET XRP Node
restart: down up

## Check MAINNET XRP Node Status
# status:	.log-component-name prerequisite-check
status:	.log-component-name
	@$(call log_info,"Show Status ${COMPONENT_NAME} ...")
	$(QUIET)for component in $(COMPONENT_TYPES); do \
		$(MAKE) -s -C $$component status 2>/dev/null; \
	done

## View MAINNET XRP Node Logs
logs:	.log-component-name
	@$(call log_info,"Logs ${COMPONENT_NAME} ...")
	$(QUIET)for component in $(COMPONENT_TYPES); do \
		$(MAKE) -C $$component logs; \
	done

## Tail (Follow) MAINNET XRP Node Logs
tail-logs:	.log-component-name
	@$(call log_info,"Logs (Tail) ${COMPONENT_NAME} ...")
	$(QUIET)for component in $(COMPONENT_TYPES); do \
		$(call log_header,"$$component"); \
		$(MAKE) -C $$component tail-logs; \
	done

## @section Maintenance
## Clean up (optional, depending on your needs)
## @param FORCE=true Overwrite the file
clean:	.log-component-name down
	$(QUIET)if [ "$(FORCE)" = "true" ]; then \
		$(call log_warn,"Force Cleaning up ${COMPONENT_NAME}  resources... + Remove Volumes"); \
		for component in $(COMPONENT_TYPES); do \
			$(call log_header,"$$component"); \
			$(MAKE) -C $$component clean; \
		done
	fi

## Pull (optional, depending on your needs)
pull:	.log-component-name
	@$(call log_info,"Pulling New Images ${COMPONENT_NAME} resources...")
	$(QUIET)for component in $(COMPONENT_TYPES); do \
		$(MAKE) -C $$component pull; \
	done


## @section Test
test-rpc:	.log-component-name
	@$(call log_info,"Testing ${COMPONENT_NAME} resources...")
	$(QUIET)for component in $(COMPONENT_TYPES); do \
		$(MAKE) -C $$component test-rpc; \
	done

# Line to add to any Makefile - generates the 'help' target from the Makefile comments
# Add to the end of the Makefile
include ${MAKE_D_DIR}/tools/Makefile-help.mk
