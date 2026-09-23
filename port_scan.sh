#!/bin/bash

# ======================================
#        BASH PORT SCANNER
# ======================================

# ---- Colors (highlight only) ----
DARK_RED="\033[38;5;88m"
BLUE="\033[34m"
GREEN="\033[32m"
BOLD="\033[1m"
RESET="\033[0m"

# ---- Usage ----
if [[ "$1" != "-IP" || -z "$2" ]]; then
    echo "Usage: $0 -IP <target_ip>"
    exit 1
fi

TARGET="$2"

# ---- Banner ----
printf "========================================\n"
printf "        ${DARK_RED}${BOLD}BASH PORT SCANNER${RESET}\n"
printf "========================================\n\n"

printf "${BLUE}Target :${RESET} %s\n" "$TARGET"
printf "${BLUE}Range  :${RESET} 1-1024\n\n"

# ---- Table Header ----
printf "${DARK_RED}%-10s | %-10s${RESET}\n" "PORT" "STATUS"
printf "-----------------------------\n"

# ---- Temp file ----
TMP_FILE=$(mktemp)

# ---- Cleanup ----
trap 'rm -f "$TMP_FILE"' EXIT

# ---- Scan Function ----
scan_port() {
    port=$1
    timeout 0.4 bash -c "echo >/dev/tcp/$TARGET/$port" 2>/dev/null

    if [[ $? -eq 0 ]]; then
        echo "$port OPEN" >> "$TMP_FILE"
    fi
}

# ---- Loading Animation ----
loading() {
    pid=$1
    frames=("⠋" "⠙" "⠹" "⠸" "⠼" "⠴" "⠦" "⠧" "⠇" "⠏")
    i=0

    while kill -0 "$pid" 2>/dev/null; do
        printf "\rScanning ports %s" "${frames[i]}"
        i=$(( (i+1) %10 ))
        sleep 0.1
    done

    printf "\r%-40s\r" " "
}

# ---- Start Scan ----
(
for port in {1..1024}; do
    scan_port "$port" &
done
wait
) &

SCAN_PID=$!
loading "$SCAN_PID"
wait "$SCAN_PID"

# ---- Output Results ----
OPEN_COUNT=0

while read -r port status; do
    printf "%-10s | ${GREEN}%-10s${RESET}\n" "$port" "$status"
    ((OPEN_COUNT++))
done < <(sort -n "$TMP_FILE")

# ---- Finish ----
printf "\n${BOLD}Scan Complete${RESET} — %d open port(s)\n" "$OPEN_COUNT"
