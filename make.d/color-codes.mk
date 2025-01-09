# Color Definitions
NO_COLOR=\033[0m

GREY=\033[0;100m
RED=\033[0;31m
GREEN=\033[0;32m
YELLOW=\033[0;33m
BLUE=\033[0;34m
PURPLE=\033[0;35m
MAGENTA=\033[0;35m
CYAN=\033[0;36m
WHITE=\033[0;37m
RESET=\e[m

LIGHT_BLACK=\033[1;30m

# Bold colors
BOLD=\033[1m
BOLD_RED=\033[1;31m
BOLD_GREEN=\033[1;32m
BOLD_YELLOW=\033[1;33m
BOLD_BLUE=\033[1;34m
BOLD_MAGENTA=\033[1;35m
BOLD_CYAN=\033[1;36m
BOLD_WHITE=\033[1;37m

# Horizontal rule
HR="---------------------------------------------------"

.PHONY: print-colors

print-colors:
	@echo -e "Terminal Color Codes:"
	@echo -e "Reset:        \033[0m     [0m"
	@echo -e "Bold:         \033[1m     [1m"
	@echo -e "Underline:    \033[4m     [4m"
	@echo -e ""
	@echo -e "Text Colors:"
	@echo -e "Black:        \033[0;30m  [0;30m"
	@echo -e "Red:          \033[0;31m  [0;31m"
	@echo -e "Green:        \033[0;32m  [0;32m"
	@echo -e "Yellow:       \033[0;33m  [0;33m"
	@echo -e "Blue:         \033[0;34m  [0;34m"
	@echo -e "Purple:       \033[0;35m  [0;35m"
	@echo -e "Cyan:         \033[0;36m  [0;36m"
	@echo -e "White:        \033[0;37m  [0;37m"
	@echo -e ""
	@echo -e "Bright/Bold Colors:"
	@echo -e "Bright Black: \033[1;30m  [1;30m"
	@echo -e "Bright Red:   \033[1;31m  [1;31m"
	@echo -e "Bright Green: \033[1;32m  [1;32m"
	@echo -e "Bright Yellow:\033[1;33m  [1;33m"
	@echo -e "Bright Blue:  \033[1;34m  [1;34m"
	@echo -e "Bright Purple:\033[1;35m  [1;35m"
	@echo -e "Bright Cyan:  \033[1;36m  [1;36m"
	@echo -e "Bright White: \033[1;37m  [1;37m"
	@echo -e ""
	@echo -e "Background Colors:"
	@echo -e "Black BG:     \033[40m    [40m"
	@echo -e "Red BG:       \033[41m    [41m"
	@echo -e "Green BG:     \033[42m    [42m"
	@echo -e "Yellow BG:    \033[43m    [43m"
	@echo -e "Blue BG:      \033[44m    [44m"
	@echo -e "Purple BG:    \033[45m    [45m"
	@echo -e "Cyan BG:      \033[46m    [46m"
	@echo -e "White BG:     \033[47m    [47m"
	@echo -e ""
	@echo -e "Combinations (Text + Background):"
	@echo -e "Red on Green: \033[31;42m [31;42m"
	@echo -e "Reset color after each example to show true color"
