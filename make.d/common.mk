
# # Increasing verbosity levels when running make
# make -n   # Dry run (print commands without executing)
# make -s   # Silent mode (suppress command echoing)
# make -d   # Debug mode (extensive output about make's decision process)

# SHELL := /bin/sh -x

# Can be called like:
# make VERBOSE=1 some-target  # Shows all commands
# make some-target             # Suppresses command output

# Verbosity Control
VERBOSE ?= 0
DEBUG   ?= 0

# Path to the YAML configuration file
CONFIG_FILE := config.yml
# Output file to store environment variables
ENV_FILE := .env
# Default prefix for environment variables
ENV_PREFIX ?= CONSTELLATION_
# make ENV_PREFIX=MYAPP_ .env

# Quiet command prefix
QUIET = $(if $(filter 1,$(VERBOSE)),,@)

define log_debug
if [ "$(DEBUG)" = "1" ]; then \
	printf "$(BLUE)  [DEBUG]$(RESET) %s\n" $(1); \
fi
endef

# Logging Macros with Color
define log_header
	sh -c ' \
		uppercase=$$(echo $(1) | tr "[:lower:]" "[:upper:]"); \
		printf "$(YELLOW)═══════╣ %s ╠═══════$(RESET)\n" "$$uppercase"; \
	'
endef

define log_header_simple
	@sh -c ' \
	uppercase=$$(echo $(1) | tr "[:lower:]" "[:upper:]"); \
	printf "$(YELLOW)════════╣ %s ╠════════$(RESET)\n" "$$uppercase"; \
	'
endef

# Logging Macros with Color
define log_info
	printf "$(CYAN)   [INFO]$(RESET) %s\n" $(1)
endef

define log_success
	printf "$(GREEN)[SUCCESS]$(RESET) %s\n" $(1)
endef

define log_warn
	printf "$(YELLOW)   [WARN]$(RESET) %s\n" $(1)
endef

define log_error
	printf "$(RED)  [ERROR]$(RESET) %s\n" $(1)
endef

# Function to check if a specific node is enabled
define is_component_enabled
if [ -f "$(1)/.env" ]; then \
	if grep -q "ENABLED=True" "$(1)/.env"; then \
		echo "ENABLED"; \
	else \
		echo "DISABLED"; \
	fi; \
else \
	echo "DISABLED"; \
fi
endef

LOCK_FILE := .lock
# Lock file check with optional custom message
define check_lock
	@if [ -f "$(LOCK_FILE)" ]; then \
		printf "%s\n" $(1); \
		exit 1; \
	fi
endef

define code_check
	$(call log_info,"Params: $(1)")
	$(call log_success,"Code Check $(1)"); \
	addr="$(1)"; \
	params="[\"$$addr\",\"latest\"]"; \
	$(call log_info,"Params: $$params")
endef

.PHONY: lock unlock .lock-file-add .lock-file-remove
# Generate lock file
.lock-file-add:
	$(QUIET)if [ ! -f "$(LOCK_FILE)" ]; then \
		touch "$(LOCK_FILE)"; \
		$(call log_info,"Lock file created at: $(LOCK_FILE)"); \
	else \
		$(call log_warn,"Lock file already exists at: $(LOCK_FILE)"); \
	fi

# Remove lock file if it exists
.lock-file-remove:
	$(QUIET)if [ -f "$(LOCK_FILE)" ]; then \
		$(call log_info,"Lock file found at: $(LOCK_FILE)"); \
		rm "$(LOCK_FILE)"; \
		$(call log_success,"Lock file removed: $(LOCK_FILE)"); \
	else \
		$(call log_warn,"No lock file found at: $(LOCK_FILE)"); \
	fi

lock: .lock-file-add

unlock: .lock-file-remove

.PHONY: .log-current-directory
.log-current-directory:
	$(QUIET)$(call log_info,"Current directory: $(shell pwd)")

.PHONY: .log-component-name
.log-component-name:
	$(QUIET)$(call log_header_simple,"${COMPONENT_NAME}")

## Verbosity Help Target
help-verbosity:
	@printf "$(LIGHT_BLACK)Verbosity Control:$(RESET)\n"
	@printf "  make VERBOSE=1   - Show all commands\n"
	@printf "  make DEBUG=1     - Show debug messages\n"
	@printf "  Combine with targets, e.g., 'make VERBOSE=1 example-target'\n\n"

# Example Target
example-target:	help-verbosity
	@printf "$(LIGHT_BLACK)Test/Show Logging:$(RESET)\n"
	@$(call log_debug,"This is an debug message")
	$(QUIET)sleep 1
	@$(call log_info,"This is a info message")
	$(QUIET)sleep 1
	@$(call log_success,"This is a success message")
	$(QUIET)sleep 1
	@$(call log_warn,"This is a warning message")
	@$(call log_error,"This is an error message")

.PHONY: check-enabled-status check-env-file
print-env-file:
	@if [ "$(DEBUG)" = "1" ]; then \
		for file in $(wildcard .env); do \
			cat $$file; \
		done \
	fi

check-env-file:
	$(if $(wildcard .env),,$(error .env file not found in current directory))
	@$(call log_success,".env File: Exists")

# $(if $(wildcard .lock),$(error Lock file .lock exists - cannot proceed),)
# Out Of Band - Change Lock .lock
check-lock-file-status: .log-current-directory
	@$(call log_info,"Checking For Change Lock File $(LOCK_FILE)")
	@$(call check_lock,"Error: Cannot proceed - directory is locked - $(LOCK_FILE)")
	@$(call log_success,"No lock file [$(LOCK_FILE)] detected")

check-enabled-status: .log-current-directory check-env-file print-env-file
	@$(call log_info,"Checking ENABLED status")
	@if ! grep -q "^ENABLED=" .env; then \
		$(call log_error,"ENABLED variable not found in .env file"); \
		exit 1; \
	fi
	@enabled_value=$$(grep -oP '^ENABLED=\K\w+' .env | tr '[:upper:]' '[:lower:]'); \
	if [ "$$enabled_value" = "true" ]; then \
		$(call log_success,"ENABLED=$$enabled_value"); \
	else \
		$(call log_warn,"ENABLED is set to '$$(grep -oP '^ENABLED=\K\w+' .env | tr '[:upper:]' '[:lower:]')' but must be 'true'"); \
		$(call log_warn,"Skipping ...."); \
		exit 127; \
	fi

prerequisite-check: check-lock-file-status check-enabled-status
	$(call log_info,"Checking ENABLED status")

## Generate .env file from YAML
.generate-config-from-yaml-orig:
	@$(call log_info,"Generating environment variables with prefix '$(ENV_PREFIX)' from $(CONFIG_FILE)...")
	@bash -c 'pwd && source ./make.d/parse_yaml.sh && parse_yaml $(CONFIG_FILE) $(ENV_PREFIX) > $(ENV_FILE)'
	@$(call log_success,".env file created.")

.combine-yaml-files:
	@$(call log_info,"Combining YAML files...")
	@bash -c 'cat secrets.yml anchors.yml $(CONFIG_FILE) > combined.yml'
	@$(call log_success,"YAML files combined.")

.process-yaml-file:
	@$(call log_info,"Processing YAML file...")
	@bash -c "docker run --rm -i -v ${PWD}:/workdir mikefarah/yq -P 'explode(.)' /workdir/combined.yml" > processed.yml
	@$(call log_success,"YAML file processed.")

.clean-yaml-files:
	@$(call log_info,"Cleaning up YAML files...")
# @bash -c "yq 'del(."x-*")' processed.yml > cleaned.yml"
	@bash -c "docker run --rm -i -v ${PWD}:/workdir mikefarah/yq 'del(."x-*")' /workdir/processed.yml" > cleaned.yml
	@$(call log_success,"YAML files cleaned up.")

.remove-yaml-files:
	@$(call log_info,"Cleaning up YAML files...")
	@rm -f combined.yml processed.yml cleaned.yml
	@$(call log_success,"YAML files cleaned up.")

## Generate .env file from YAML
.generate-config-from-yaml: .combine-yaml-files .process-yaml-file .clean-yaml-files
	@$(call log_info,"Generating environment variables with prefix '$(ENV_PREFIX)' from $(CONFIG_FILE)...")
	@bash -c 'pwd && source ./make.d/parse_yaml.sh && parse_yaml processed.yml $(ENV_PREFIX) > $(ENV_FILE)'
	@$(call log_success,".env file created.")
	@$(MAKE) .remove-yaml-files

.pause_for_effect:
	@$(call log_debug,"Sleep for 1 Seconds")
	@sleep 1

# include ${MAKE_D_DIR}/blockchain.mk
