.PHONY: help
help:
	@MAKEFILES="$(MAKEFILE_LIST)" ${MAKE_D_DIR}/tools/generate-makefile-help
