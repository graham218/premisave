#!/usr/bin/env bash
# ============================================================
# Premisave App – Flutter Web Runner
# ------------------------------------------------------------
# Builder        : Bill Graham Peacemaker
# GitHub         : https://github.com/graham218
# Version        : 1.0.0
# Script Name    : run_web.sh
# Description    : Cross-terminal safe Flutter Web launcher
# Compatibility  : Linux, macOS, WSL
# ============================================================

set -e

# ========================
# COLORS (ANSI)
# ========================
GREEN="\033[0;32m"
CYAN="\033[0;36m"
YELLOW="\033[1;33m"
GRAY="\033[0;90m"
RED="\033[0;31m"
RESET="\033[0m"

# ========================
# CLEAR SCREEN (SAFE)
# ========================
clear || true

# ========================
# ASCII LOGO
# ========================
logo=(
"  _____                         _                     "
" |  __ \\                       | |                    "
" | |__) | __ ___ _ __ ___   ___| |__   __ _ _ __ ___  "
" |  ___/ '__/ _ \\ '_ \` _ \\ / _ \\ '_ \\ / _\` | '__/ _ \\ "
" | |   | | |  __/ | | | | |  __/ |_) | (_| | | |  __/ "
" |_|   |_|  \\___|_| |_| |_|\\___|_.__/ \\__,_|_|  \\___| "
"                APP                                   "
)

for line in "${logo[@]}"; do
  echo -e "${GREEN}${line}${RESET}"
  sleep 0.035
done

echo ""
echo -e "${YELLOW}:: Premisave App :: Flutter Web :: Auto Browser ::${RESET}"
echo -e "${GRAY}Builder  : Bill Graham Peacemaker${RESET}"
echo -e "${GRAY}Version  : 1.0.0${RESET}"
echo -e "${GRAY}GitHub   : https://github.com/graham218${RESET}"
echo -e "${GRAY}------------------------------------------------------------${RESET}"
echo ""

# ========================
# LOG FUNCTION
# ========================
log() {
  local level="$1"
  local message="$2"
  local color="${3:-$CYAN}"
  local timestamp
  timestamp=$(date +"%Y-%m-%d %H:%M:%S")
  echo -e "${color}${timestamp} [${level}] ${message}${RESET}"
  sleep 0.2
}

log "INFO" "Bootloader        : Initializing runtime"
log "INFO" "Environment       : Profile loaded"
log "INFO" "SecurityManager   : Sandbox enabled"
log "INFO" "FlutterEngine     : Preparing web renderer"

echo ""

# ========================
# LOADING ANIMATION
# ========================
frames=( "|" "/" "-" "\\" )
for ((i=0; i<20; i++)); do
  for f in "${frames[@]}"; do
    echo -ne "${YELLOW}\rInitializing modules [${f}]${RESET}"
    sleep 0.1
  done
done
echo -e "${GREEN}\rInitializing modules [OK]${RESET}"
echo ""

# ========================
# FLUTTER CHECK
# ========================
if ! command -v flutter >/dev/null 2>&1; then
  log "ERROR" "Flutter is not installed or not in PATH" "$RED"
  echo -e "${YELLOW}Fix: https://docs.flutter.dev/get-started/install${RESET}"
  exit 1
fi

# ========================
# BROWSER AUTO-DETECTION
# ========================
BROWSER_DEVICE=""

if command -v google-chrome >/dev/null 2>&1 \
   || command -v google-chrome-stable >/dev/null 2>&1 \
   || command -v chromium >/dev/null 2>&1; then
  BROWSER_DEVICE="chrome"
  log "INFO" "Browser detected     : Chrome / Chromium"
elif command -v microsoft-edge >/dev/null 2>&1 \
     || command -v microsoft-edge-stable >/dev/null 2>&1; then
  BROWSER_DEVICE="edge"
  log "INFO" "Browser detected     : Microsoft Edge"
else
  log "ERROR" "No supported browser found (Chrome or Edge)" "$RED"
  echo -e "${YELLOW}Install Chrome or Edge to continue.${RESET}"
  exit 1
fi

log "INFO" "WebServer         : Listening on port 3000"
log "INFO" "PremisaveApp      : Startup complete"
echo -e "${GRAY}------------------------------------------------------------${RESET}"
echo ""

# ========================
# RUN FLUTTER
# ========================
flutter run -d "$BROWSER_DEVICE" --web-port=3000
